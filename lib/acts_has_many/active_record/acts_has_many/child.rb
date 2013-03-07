module ActiveRecord
  module ActsHasMany

    # Class methods:
    #   <tt>has_many_through_update</tt>
    #
    # Instance methods:
    #   <tt>has_many_update</tt>
    #   <tt>actual?</tt>
    #   <tt>destroy</tt>
    #   <tt>destroy!</tt>
    module Child

      # <tt>has_many_update</tt> (return: array) - [new_record, delete_record]
      # options: data (type: hash) - data for updte
      def has_many_update data
        data = { model.compare => ''}.merge data

        has_many_cleaner data.symbolize_keys
      end

      # destroy with check actuality
      def destroy
        return false if actual? false
        super
      end

      # original destroy
      def destroy!
        self.class.superclass.instance_method(:destroy).bind(self).call
      end

      # <tt>actual?</tt> - check the acutuality of element in has_many table
      # options: exclude (boolean, default: true) - ignore one record or no
      def actual? exclude = true
        actual = 0
        model.dependent_relations.each do |dependent_relation|
          tmp = self.send dependent_relation
          actual += tmp.all.size
        end

        exclude ? actual > 1 : actual > 0
      end
    end

  private

    # <tt>has_many_cleaner</tt> - base mothod
    def has_many_cleaner data
      compare = { model.compare => data[model.compare] }

      new_record = self
      del_record = nil

      if actual?
        new_record = model.where(compare).first_or_create data
      else
        object_tmp = model.where(compare).first
        if object_tmp.nil?
          if new_record.id.nil?
            new_record = model.where(compare).first_or_create data
          else
            if data[model.compare].blank?
              del_record, new_record = new_record, nil
            else
              update_attributes data
            end
          end
        else
          del_record = (new_record.id == object_tmp.id) ? nil : new_record
          new_record = object_tmp
        end
      end
      [new_record, del_record]
    end


    module ChildThrough

      # <tt>has_many_through_update</tt> (return array) [ 1 - array new records, 2 - array delete records ]
      # options
      #   :update (array) - data for update (id and data)
      #   :new (array) - data for create record (data)
      #
      # +for delete records need use method destroy !!!+
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
            data = data.symbolize_keys
            record_add << where(compare => data[compare]).first_or_create(data)
            record_del.delete record_add.last
          end
        end

        [record_add, record_del]
      end
    end
  end
end
