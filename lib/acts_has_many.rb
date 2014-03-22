require 'acts_has_many/active_record/acts_has_many'
require 'acts_has_many/active_record/acts_has_many/child'
require 'acts_has_many/active_record/acts_has_many/parent'

ActiveRecord::Base.class_eval { include ActiveRecord::ActsHasMany}
