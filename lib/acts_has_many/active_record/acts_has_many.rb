module ActiveRecord
  module ActsHasMany

    # Class methods: (for use in your model)
    #   <tt>acts_has_many_for</tt>
    #   <tt>acts_has_many</tt>
    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods

      # Class methods:
      #   <tt>dependent_relations</tt>
      #   <tt>compare</tt>
      #   <tt>model</tt>
      #   <tt>has_many_through_update</tt>
      # Instance mothods:
      #   <tt>actual?</tt>
      #   <tt>has_many_update</tt>
      # Set:
      #   validates for <compare_element> (uniqueness: true, presence: true)
      def acts_has_many *opt
        options = { compare: :title, through: false }
        options.update opt.extract_options!
        options.assert_valid_keys :compare, :through
        options[:relations] = opt

        options[:relations] = self.reflect_on_all_associations(:has_many)
          .map(&:name) if options[:relations].blank?

        dependent_relations = []
        options[:relations].each do |relation|
          if reflect_on_association relation.to_sym
            dependent_relations << relation.to_s.tableize
          else
            raise ArgumentError, "No association found for name `#{relation}'. Has it been defined yet?"
          end
        end

        class_eval <<-EOV, __FILE__ , __LINE__ + 1
          def self.dependent_relations
            #{dependent_relations}
          end

          def self.compare
            '#{options[:compare]}'.to_sym
          end

          include ActiveRecord::ActsHasMany::Child
          #{'extend  ActiveRecord::ActsHasMany::ChildThrough' if options[:through]}

          def model
            #{self}
          end

          validates :#{options[:compare]}, uniqueness: true, presence: true
        EOV
      end

      # Class methods:
      #   <tt>dependent_relations</tt>
      #   <tt><relation>_attributes=</tt>
      #   <tt><relation>_collection=</tt>
      # Set:
      #   after save filter
      #   attribut accessor tmp_garbage
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
