module Resolver
  module Key

    def self.included(base)
      base.extend(ClassMethods)
      base.send(:resolver_keys)
      base.send(:include, InstanceMethods)
      base.after_save :resolver_add_keys_to_index
      base.after_destroy :resolver_remove_keys_from_index
    end

    module ClassMethods

      def key(name, options = {})
        @resolver_keys[name.to_sym] = options || {}
        define_attribute_method(name)
      end

      def find_by(key, value)
        if options = @resolver_keys[key.to_sym]
          if options[:unique]
            self.find(*Resolver.redis.get(index_name(key, value)))
          else
            self.find(Resolver.redis.smembers(index_name(key, value)))
          end
        end
      end

      def exists_with?(key, value)
        Resolver.redis.exists(index_name(key, value))
      end

      def count_with(key, value)
        if options = @resolver_keys[key.to_sym]
          if options[:unique]
            exists_with?(key, value) ? 1 : 0
          else
            Resolver.redis.scard(index_name(key, value))
          end
        end
      end

    protected

      def resolver_keys
        @resolver_keys ||= {}
        @resolver_keys
      end

      def index_name(name, value)
        options = @resolver_keys[name.to_sym]
        if options[:global]
          "#{name}:#{value}"
        else
          "#{self.to_s}:#{name}:#{value}"
        end
      end

      def write_index(key, object, options)
        value = object.send(key)
        if options[:unique]
          Resolver.redis.setnx(index_name(key, value), object.id)
        else
          if object.respond_to?(:previous_changes) && object.send(:previous_changes).include?(key.to_s)
            prev_value = object.send(:previous_changes)[key.to_s].first
            Resolver.redis.smove(index_name(key, prev_value),
                                 index_name(key, value), object.id)
          else
            Resolver.redis.sadd(index_name(key, value), object.id)
          end
        end
      end

      def clean_index(key, object, options)
        value = object.send(key)
        if options[:unique]
          Resolver.redis.del(index_name(key, value))
        else
          Resolver.redis.srem(index_name(key, value), object.id)
        end
      end

    end

    module InstanceMethods

      def resolver_add_keys_to_index
        self.class.send(:resolver_keys).each do |key,options|
          self.class.send(:write_index, key, self, options)
        end
      end

      def resolver_remove_keys_from_index
        self.class.send(:resolver_keys).each do |key,options|
          self.class.send(:clean_index, key, self, options)
        end
      end

    end

  end
end
