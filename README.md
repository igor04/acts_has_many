# acts_has_many

Acts_has_many gem gives functional for clean update elements *has_many* relation
(additional is has_many :trhough). The aim is work with has_many relation without gerbage,
every record must be used, othervise there will be no record.

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
  has_many :users

  acts_has_many :users # list necessary relations
end

# acts_has_many options:
# 	list relations(it maybe missed if you use has many relation which are written above)
# 	:compare( string or symbol; default: :title) - name column with unique elements in table
# 	:through( boolean; default: false) - if you use has_many :through


company = Company.create(:title => 'Microsoft')
Company.dependent_relations # => ["users"]
Company.compare             # => :title

company.actuale? # => false

user = User.create do |user|
	user.company = company
	# ...
end

company.actuale?        # => true
company.actuale? :users # => false ( exclude 1 record of current relation)

company   # => <Company id: 1, title: "Microsoft"> 

update_record, delete_record  = company.has_many_update({ title: 'Google'}, :users)
# or
#   update_record, delete_record  = company.update_with_users({ title: 'Google'})

update_record # => <Company id: 1, title: "Google"> 
delete_record # => nil

user2 = User.create do |user|
	user.company = company
	# ...
end

company.actuale? # => true
company.actuale? :users # => true

# if you want to destroy user
#   user2.destroy # => user will be destroyed, company will rollback (because company is used by other user)

company   # => <Company id: 1, title: "Google"> 
update_record, delete_id  = company.has_many_update({ title: 'Apple'}, :users)
update_record # => <Company id: 2, title: "Apple"> 
delete_record # => nil

user2.company = update_record
user2.save

# if you want to destroy user now
#   user2.destroy # => user and company will be destroyed (because company is used only by user2)

Company.all # [#<Company id: 1, title: "Google">, #<Company id: 2, title: "Apple"]

company.destroy # => false (because company is used)

companu 	# => <Company id: 1, title: "Google">
update_record, delete_record  = company.has_many_update({ title: 'Apple'}, :users)
update_record 	# => <Company id: 2, title: "Apple"> 
delete_record 	# => <Company id: 1, title: "Google">

user2.company = update_record
user2.save

company.destroy # => true

# this situation with delete_record best way is "company.delete" because you miss unnecessary check actuality

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
  has_many :user_company

  acts_has_many :users, :through => true
end

class User < ActiveRecord::Base
  has_many :user_company, :dependent => :destroy
  has_many :companies, :through => :user_company
end

new_rows, delete_ids = Company.has_many_update_through( update: data, new: date, relation: :users)

user.companies = new_rows # update user companies

Company.delete(delete_ids) # for delete_ids from has_many_update_through best way is to use "delete" and miss unnecessary check
```

### Use acts_has_many_for with acts_has_many
When use acts_has_many_for you can user attributes
```ruby

user = User.create name: 'Bill', company_attributes: { title: 'Microsoft' }

or

user.company_attributes = { title: 'Google' }

or 

user.company_attributes = Company.first
user.save

# if you use has_many_through you can use collection

user = User.create name: 'Bob', companies_collection: [{title: 'MS'}, {title: 'Google'}]

or

user.companies_collection = [{title: 'MS'}, {title: 'Google'}]

or

user.company_collection = Company.all
user.save

```

Contributing
------------
You can help improve this project.

Here are some ways *you* can contribute:

* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up inconsistent whitespace)
* by refactoring code
* by closing [issues](https://github.com/igor04/acts_has_many/issues)
* by reviewing patches


Submitting an Issue
-------------------
We use the [GitHub issue tracker](https://github.com/igor04/acts_has_many/issues) to track bugs and
features. Before submitting a bug report or feature request, check to make sure it hasn't already
been submitted. You can indicate support for an existing issuse by voting it up. When submitting a
bug report, please include a [Gist](http://gist.github.com/) that includes a stack trace and any
details that may be necessary to reproduce the bug, including your gem version, Ruby version, and
operating system. Ideally, a bug report should include a pull request with failing specs.
