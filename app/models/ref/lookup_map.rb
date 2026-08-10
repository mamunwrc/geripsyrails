module Ref
  module LookupMap
    module Mixin
      extend ActiveSupport::Concern

      class_methods do
        def default_lookup_group(name=nil)
          return @__DEFAULT_GROUP_NAME__ unless name
          @__DEFAULT_GROUP_NAME__ = name
        end

        def create_mapping(name=:default)
          group = lookup_groups[name] ||= Ref::LookupMap::Group.new(name)
          yield group
          __add_lookup_scope__(group)
        end

        def lookup_query(&block)
          return @__LOOKUP_QUERY__ unless block_given?
          @__LOOKUP_QUERY__ = block
        end

        def lookup_groups
          @__LOOKUP_GROUPS__ ||= Hashie::Mash.new
        end

        def __add_lookup_scope__(group)
          return if __lookup_scope_added__?(group.name)
          define_singleton_method group.scope_name do |full_path, value|
            branch, path = *full_path.split('.')
            lookup = group[branch].to_lookup(path,value)
            lookup.group = default_lookup_group if default_lookup_group && lookup.group == :default
            lookup_query[lookup].first.try(:keyvalue)
          end
          __lookup_scope_added__!(group.name)
        end

        def __lookup_scopes__
          @__LOOKUP_SCOPES__ ||= {}
        end

        def __lookup_scope_added__?(name)
          !!__lookup_scopes__[name]
        end

        def __lookup_scope_added__!(name)
          __lookup_scopes__[name] = true
        end
      end
    end

    class Group
      def initialize(name)
        @name = name
        @branches = Hashie::Mash.new
      end

      attr_reader :name, :branches

      def scope_name
        return :lookup if @name == :default
        :"#{@name}_lookup"
      end

      def branch(name, &block)
        branch = branches[name] ||= Branch.new(name, self)
        branch.define(&block) if block_given?
      end

      def [](branch)
        branches[branch]
      end
    end

    class Branch
      def initialize(name, group)
        @name = name
        @group = group
        @map = Hashie::Mash.new
      end

      attr_reader :name, :group

      def define
        yield @map
      end

      def to_lookup(path, keyname)
        Hashie::Mash.new({
          group: group.name,
          prefix: @map[path],
          name: keyname
        })
      end
    end

  end
end

