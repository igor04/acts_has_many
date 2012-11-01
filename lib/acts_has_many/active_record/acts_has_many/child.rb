module ActiveRecord
  module ActsHasMany

    # Added:
    #   class methods:
    #     +has_many_through_update+
    #
    #   instance methods:
    #     +has_many_update+
    #     +update_with_<relation>+
    #     +actuale?+

    module Child

      def self.included base

        # Generate methods:
        #   update_with_<relation>(data)

        base.dependent_relations.each do |relation|
          define_method("update_with_#{relation}") do |data|
            has_many_update data, relation
          end
        end
      end

      #
      # +has_many_update+ (return: array) - [new_record, delete_record]
      # options: (Hash is deprecated, list parameters)
      #   data (type: hash) - data for updte
      #   relation (type: str, symbol) - current relation for check
      #

      def has_many_update data, relation
        data = { model.compare => ''}.merge data

        if relation.blank?
          warn "[ARRGUMENT MISSING]: 'has_many_update' don't know about current relation, and check all relations"
        end

        has_many_cleaner data.symbolize_keys, relation
      end

      #
      # +actuale?+ - check the acutuality of element in has_many table
      # options:
      #   relation (String, Symbol) - for exclude one record from current relation
      #

      def actuale? opt = ""
        relation = opt.to_s.tableize

        actuale = false
        model.dependent_relations.each do |dependent_relation|
          tmp = self.send dependent_relation
          if relation == dependent_relation
            actuale ||= tmp.all.size > 1
          else
            actuale ||= tmp.exists?
          end
        end
        actuale
      end
    end

  private

    #
    # +destroy_filter+ - use with before_filter, and protect actuale records
    #

    def destroy_filter
      not actuale?
    end

    #
    # +has_many_cleaner+ - base mothod
    #

    def has_many_cleaner data, relation
      compare = { model.compare => data[model.compare] }

      new_record = self
      del_record = nil

      if actuale? relation
        new_record = model.where(compare).first_or_create data
      else
        object_tmp = model.where(compare).first
        unless object_tmp.nil?
          del_record = (new_record.id == object_tmp.id) ? nil : new_record
          new_record = object_tmp
        else
          if new_record.id.nil?
            new_record = model.where(compare).first_or_create data
          else
            if data[model.compare].blank?
              del_record, new_record = new_record, nil
            else
              update_attributes data
            end
          end
        end
      end
      [new_record, del_record]
    end


    module ChildThrough

      #
      # +has_many_through_update+ (return array) [ 1 - array new records, 2 - array delete records ]
      # options
      #   :update (array) - data for update (id and data)
      #   :new (array) - data for create record (data)
      #
      # +for delete records need use method destroy !!!+
      #

      def has_many_through_update(options)
        record_add = []
        record_del = []

        options[:update].each do |id, data|
          add, del = find(id).has_many_update data, options[:relation]
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
