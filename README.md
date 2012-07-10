# acts_has_many

## Installation

Add this line to your application's Gemfile:

    gem 'acts_has_many'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_has_many

## Usage
```ruby
class User < ActiveRecord::Base
  belongs_to :company, dependent: :destroy
end

class Company < ActiveRecord::Base
  has_many :users

  acts_has_many # after necessary relation
end

# OR

class Company < ActiveRecord::Base
  acts_has_many relations: [:users] # array necessary relations
  
  has_many :users
end

# acts_has_many options:
# 	:relations( array; default: has many relation which are written above) - necessary relations
# 	:compare( string or symbol; default: :title) - name column with unique elements in table
# 	:through( boolean; default: false) - if you use has_many :through


company = Company.create(:title => 'Microsoft')

company.actuale? # => false

user = User.create do |user|
	user.company = company
	# ...
end

company.actuale? # => true
company.actuale? relations: :users # => false ( exclude 1 record of current relation)

company.depend_relations # => ["users"]
company.model 	# => Company
company.compare # => :title

company.id 	# => 1
update_id, delete_id  = company.has_many_update(data: { title: 'Google'}, relation: :users)
update_id 	# => 1
delete_id 	# => nil
company.title # => 'Google'

# ... update user with new company and other code

user2 = User.create do |user|
	user.company = company
	# ...
end

company.actuale? # => true
company.actuale? relations: :users # => true

# Suggestion: if you want to destroy user
user2.destroy # user will be destroyed, company will rollback (because company is used by other user)

company.id 	# => 1
update_id, delete_id  = company.has_many_update(data: { title: 'Apple'}, relation: :users)
update_id 	# => 2
delete_id 	# => nil

user2.company = Company.find(update_id)
user2.save

# Suggestion: if you want to destroy user now
user2.destroy # user and company will be destroyed (because company is used only by user2)

Company.all # [#<Company id: 1, title: "Google">, #<Company id: 2, title: "Apple"]

company.destroy # => false

companu.id 	# => 1
update_id, delete_id  = company.has_many_update(data: { title: 'Apple'}, relation: :users)
update_id 	# => 2
delete_id 	# => 1

# ... update user with company

company.destroy # => true

# this situation with delete_id best way is "company.delete" because you miss unnecessary check actuality
```

### has_many_update_through used with has_many :through and get array parameters
has_many_update_through is helpful method for has_many_update and use it, you can use has_many_update 
here too, and to do without has_many_update_through
	
For example:

```ruby
class UserCompany < ActiveRecord::Base
  belongs_to :user
  belongs_to :company

class Company < ActiveRecord::Base
  has_many :users, :through => :user_company
  acts_has_many :through => true
  
  has_many :user_company
end

class User < ActiveRecord::Base
  has_many :user_company, :dependent => :destroy
  has_many :companies, :through => :user_company
end

new_rows, delete_ids = Company.has_many_update_through( update: data, new: date, relation: :users)

user.companies = new_rows # update user companies

Company.delete(delete_ids) # for delete_ids from has_many_update_through best way is to use "delete" and miss unnecessary check
```