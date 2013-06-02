module ActiveRecord
  module ActsHasMany
    extend ActiveSupport::Concern

    module ClassMethods
      def acts_has_many *opt, &block
        options = {compare: :title, through: false}
        options.update opt.extract_options!
        options.assert_valid_keys :compare, :through

        options[:relations] = opt
        if options[:relations].blank?
          options[:relations] = self.reflect_on_all_associations(:has_many).map(&:name)
        end

        dependent_relations = []
        options[:relations].each do |relation|
          if reflect_on_association relation.to_sym
            dependent_relations << relation.to_s.tableize
          else
            raise ArgumentError, "No association found for name `#{relation}'. Has it been defined yet?"
          end
        end

        if block_given?
          self.class.send :define_method, :condition, block
        else
          self.class.send :define_method, :condition do |data|
            where options[:compare] => data[options[:compare]]
          end
        end

        class_eval <<-EOV, __FILE__ , __LINE__ + 1
          def self.dependent_relations
            #{dependent_relations}
          end

          include ActiveRecord::ActsHasMany::Child
          #{"extend  ActiveRecord::ActsHasMany::ChildThrough" if options[:through]}

          #{"validates :#{options[:compare]}, uniqueness: true" unless block_given?}
        EOV
      end

      def acts_has_many_for *relations
        class_eval <<-EOV, __FILE__ , __LINE__ + 1
          def self.dependent_relations
            #{relations}
          end

          attr_accessor :tmp_garbage

          include ActiveRecord::ActsHasMany::Parent

          after_save :clear_garbage
        EOV
      end
    end
  end
end
