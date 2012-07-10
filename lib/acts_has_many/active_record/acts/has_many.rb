module ActiveRecord
  module Acts #:nodoc:
    module HasMany
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # class methods +acts_has_many+ added:
      #
      # class method:
      #   +has_many_through_update+
      #
      # instance methods:
      #   +depend_relations+
      #   +model+
      #   +compare+
      #   +has_many_update+
      #   +actuale?+
      #
      # set +before_destroy+ callback;
      #      
      
      module ClassMethods
        
        #
        # +acts_has_many+ - available method in all model and switch on 
        #   extension functional in concrete model (need located this method
        #   after all relation or after relation which include in dependence)
        # options
        #   :compare( symbol, string)- name column for compare with other element in table
        #   :relations( array) - concrete name of depended relation
        #   :through( boolean) - off or on has_many_through_update method
        #
        
        def acts_has_many(options = {})
          depend_relations = []
          options_default = { compare: :title, through: false }

          options = options_default.merge options
              
          options[:relations] = self.reflections
            .select{ |k, v| v.macro == :has_many }
            .map{|k, v| k} if options[:relations].nil?
           
          options[:relations].each do |relation|
            depend_relations << relation.to_s.tableize
          end
            
          #
          # +has_many_through_update+ (return array) [ 1 - array objects records, 2 - array delete ids ] 
          # options 
          #   :update( array) - data for update (id and data)
          #   :new( array) - data for create record (data)
          #
          # +for delete need use method destroy !!!+
          #

          has_many_through = ''
          if(options[:through])
            has_many_through = """
              def self.has_many_through_update(options)
                record_add = []
                record_del = []
  
                # update
                options[:update].each do |id, data|
                  add, del = #{self}.find(id)
                    .has_many_update(:data => data, :relation => options[:relation])
                  record_add << add unless add.nil?
                  record_del << del unless del.nil?
                end unless options[:update].nil?
                
                # new
                unless options[:new].nil?
                  options[:new].uniq!
                  options[:new].each do |data|
                    date = data.symbolize_keys
                    record_add << #{self}
                      .where('#{options[:compare]}' => data['#{options[:compare]}'.to_sym])
                      .first_or_create(data)
                    record_del.delete record_add.last.id
                  end 
                end
                
                record_add = #{self}.where('id IN (?)', record_add) unless record_add.empty? 
                [record_add, record_del]
              end """
          end
          
          class_eval <<-EOV
            include ActiveRecord::Acts::HasMany::InstanceMethods
            def depend_relations
              #{depend_relations}
            end
            def compare
              '#{options[:compare]}'.to_sym
            end
            def model
              #{self}
            end 
            
            #{has_many_through}
            
            before_destroy :destroy_filter
          EOV
        end
      end
      
      module InstanceMethods

        #
        # +has_many_update+ ( return array) [new_id, del_id]
        # options
        #   :data( type: hash) - data for updte
        #   :relation( type: str, symbol) - modifi with tableize
        #
        
        def has_many_update(options)
          options_default = { 
            :data => { :title => ""}
          }

          options = options_default.merge options
          options[:data] = options[:data].symbolize_keys
          full_compare = { compare => options[:data][compare] }

          object_id = id
          delete_id = nil
          
          if actuale? :relation => options[:relation]
            # create new object and finish
            object = model.where(full_compare).first_or_create(options[:data])
            object_id = object.id
          else
            object_tmp = model.where(full_compare)[0]
            unless object_tmp.nil?
              # set new object and delete old
              delete_id = (object_id == object_tmp.id) ? nil : object_id
              object_id = object_tmp.id
            else
              # update old object
              if object_id.nil?
                object = model.where(full_compare).first_or_create(options[:data])
                object_id = object.id
              else
                if options[:data][compare].empty?
                  delete_id = object_id
                  object_id = nil
                else
                  update_attributes(options[:data])
                end
              end
            end
          end
          [object_id, delete_id]
        end
        
        #
        # +actuale?+ - check the acutuality of element in has_many table
        # options
        #   :relation( string, symbol) - exclude current relation 
        #
        
        def actuale? (options = { :relation => "" })
          actuale = false
          
          depend_relations.each do |relation|
            tmp = self.send(relation)
            if options[:relation].to_s.tableize == relation
              actuale ||= tmp.all.size > 1
            else
              actuale ||= tmp.exists?
            end
          end
          
          actuale
        end
      end
       
      #
      # +destroy_filter+ - method for before_destroy, check actuale record and
      # return true for delete or false for leave
      #
      
      def destroy_filter
        not actuale?
      end
    end
  end
end
