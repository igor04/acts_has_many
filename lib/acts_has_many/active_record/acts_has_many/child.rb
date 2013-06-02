module ActiveRecord
  module ActsHasMany
    module Child
      def has_many_update data
        current = self
        condition = current.class.condition(data.symbolize_keys)

        if actual? || current.new_record?
          [condition.first_or_create(data), nil]
        elsif exists = condition.first
          [exists, (current == exists ? nil : current)]
        else
          update_attributes data
          [current, nil]
        end
      end

      def destroy
        return false if actual? false
        super
      end

      def destroy!
        self.class.superclass.instance_method(:destroy).bind(self).call
      end

      def actual? exclude = true
        actual = 0
        self.class.dependent_relations.each do |dependent_relation|
          tmp = self.send dependent_relation
          actual += tmp.all.size
        end

        exclude ? actual > 1 : actual > 0
      end
    end

    module ChildThrough
      def has_many_through_update(options)
        record_add = []
        record_del = []

        options[:update].each do |id, data|
          add, del = find(id).has_many_update data
          record_add << add unless add.nil?
          record_del << del unless del.nil?
        end unless options[:update].nil?

        unless options[:new].nil?
          options[:new].uniq!
          options[:new].each do |data|
            record_add << new.has_many_update(data).first
            record_del.delete record_add.last
          end
        end

        [record_add, record_del]
      end
    end
  end
end
