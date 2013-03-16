module ActiveRecord
  module ActsHasMany

    # Class methods:
    #   <tt><relation>_attributes=</tt>
    #   <tt><relation>_collection=</tt>
    module Parent

      def self.included base

        # Generate class methods
        #   <tt><relation>_attributes=</tt> - set one element (use with belogns_to)
        #   options: data (type: Hash, existing recod, NilClass)
        #
        #   Create or update child record and set to parent when `data` is Hash
        #   Change data with delating or leaving child record when `data` is exists record, or NilClass
        #
        #   <tt><relation>_collection=</tt> - set many elements (use with has_many :through)
        #   options: data (type: Array with (exist records or Hash)
        #
        #   Create or select exists records and set to parent, unused record try destory
        base.dependent_relations.each do |relation|
          unless base.reflect_on_association relation.to_sym
            raise ArgumentError, "No association found for name `#{relation}`. Has it been defined yet?"
          end

          relation = relation.to_s
          unless base.reflect_on_association(relation.to_sym).collection?
            base.class_eval <<-EOV, __FILE__ , __LINE__ + 1
            def #{relation}_attributes= data
              self.tmp_garbage ||= {}
              current = self.#{relation}

              if data.is_a? Hash
                if current
                  new, del = current.has_many_update data
                else
                  new, del = #{relation.classify}.new.has_many_update data
                end

                self.#{relation} = new
                self.tmp_garbage.merge!({ #{relation}: del }) if del
              else
                self.#{relation} = data
                self.tmp_garbage.merge!({ #{relation}: current }) if current
              end
            end
            EOV
          else
            base.class_eval <<-EOV, __FILE__ , __LINE__ + 1
            def #{relation}_collection= data
              self.tmp_garbage ||= {}

              if data.is_a? Array
                if data.first.is_a? Hash
                  new, del = #{relation.classify}.has_many_through_update new: data
                elsif data.first.is_a? #{relation.classify}
                  new, del = data, []
                elsif data.empty?
                  new, del = [],[]
                else
                  raise ArgumentError, "Array with (Hash or " + #{relation.classify}.inspect + ") expected, got Array with " + data.first.inspect
                end

                #{relation}.each{ |t| del << t if not new.include? t }
                self.#{relation} = new
                self.tmp_garbage.merge!({ #{relation}: del }) if del.present?
              else
                raise ArgumentError, "Array expected, got " + data.inspect
              end
            end
            EOV
          end
        end
      end

    private

      #  <tt>clear_garbage</tt> work with after_save and try destroied records from tmp_garbage
      def clear_garbage
        self.tmp_garbage.each do |relation, record|
          if record.is_a? Array
            record.each { |r| r.destroy }
          else
            record.destroy
          end
        end if self.tmp_garbage.present?
        self.tmp_garbage = {}
      end
    end
  end
end
