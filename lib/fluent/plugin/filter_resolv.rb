require 'resolv'

module Fluent
  class ResolvFilter < Filter
    Plugin.register_filter('resolv', self)

    config_param :key_name,      :string, :default => 'host'
    config_param :key_postfix,   :string, :default => 'fqdn'
    config_param :remove_prefix, :string, :default => nil
    config_param :add_prefix,    :string, :default => nil

    def configure(conf)
      super
      @remove_prefix = Regexp.new("^#{Regexp.escape(remove_prefix)}\.?") unless conf['remove_prefix'].nil?
      @key_postfix   = @key_name + "_" + @key_postfix
    end

    def filter_stream(tag, es)
      new_es = MultiEventStream.new
      tag = tag.sub(@remove_prefix, '') if @remove_prefix
      tag = (@add_prefix + '.' + tag) if @add_prefix

      es.each do |time,record|
        record[@key_postfix] = Resolv.getname(record[@key_name]) rescue nil
        new_es.add(time, record)
      end
      return new_es
    end
  end
end
