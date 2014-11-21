module Oat
  module Adapters
    class JSON < Oat::Adapter
      def link(rel, opts = {})
        data[:_links][rel] = opts if opts[:href]
      end

      def properties(&block)
        data.merge! yield_props(&block)
      end

      def property(key, value)
        data[key] = value
      end

      alias_method :meta, :property

      def ret
        # no-op to maintain interface compatibility with the Siren adapter
      end

      def type(*types)
        @root_name = types.first.to_sym
      end

      def entity(name, obj, serializer_class = nil, context_options = {}, &block)
        entity_serializer = serializer_from_block_or_class(obj, serializer_class, context_options, &block)
        data[entity_name(name)] = entity_serializer ? entity_serializer.to_hash : nil
      end

      def entities(name, collection, serializer_class = nil, context_options = {}, &block)
        data[entity_name(name)] = collection.map do |obj|
          entity_serializer = serializer_from_block_or_class(obj, serializer_class, context_options, &block)
          entity_serializer ? entity_serializer.to_hash : nil
        end
      end
      alias_method :collection, :entities

      def entity_name(name)
        # entity name may be an array, but JSON only uses the first
        name.respond_to?(:first) ? name.first : name
      end

      private :entity_name

      def to_hash
        @serializer.context[:include_root] ? { @root_name => data } : data
      end
    end
  end
end
