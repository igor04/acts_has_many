# acts_has_many [![Build Status](https://travis-ci.org/igor04/acts_has_many.png?branch=master)](https://travis-ci.org/igor04/acts_has_many)

Acts_has_many gem gives functional for clean update elements `has_many` relation
(additional is `has_many :trhough`). The aim is work with has_many relation without gerbage,
every record must be used, othervise there will be no record.

## Installation

Add this line to your application's Gemfile:

    gem 'acts_has_many'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install acts_has_many

## Usage
1. To initialize gem you can use `acts_has_many` only, or `acts_has_many` with `acts_has_many_for` together
2. In model where you set `acts_has_many` will work clearly (all records used, no duplications)
3. Should use `dependent: :destroy`

4. If only `acts_has_many` is used:
```ruby
    class User < ActiveRecord::Base
      belongs_to :company, dependent: :destroy
    end

    class Company < ActiveRecord::Base
      has_many :users

      acts_has_many :users
    end
```
    In this case you have `has_many_update` method:
```ruby
    Company.first.has_many_update {title: 'Google'}
```
    if you use `acts_has_many` with `through: true` paramters:
```ruby
    new_records, delete_ids = Company.has_many_through_update(update: data, new: date)
```

5. If you use `acts_has_many` with `acts_has_many_for`
```ruby
    class User < ActiveRecord::Base
      belongs_to :company, dependent: :destroy

      acts_has_many_for :company
    end

    class Company < ActiveRecord::Base
      has_many :users

      acts_has_many :users
    end
```
    In this case you can use the same that is in 4-th point and also:
```ruby
    User.first.company_attributes = {title: 'Google'}
```
    if you use `acts_has_many` with `through: true` paramters
```ruby
    User.first.companies_collection = [{title: 'Google'}, {title: 'Apple'}]
```

More
----
   `acts_has_many` options:
   >* list relations or after necessary relations
   >* :compare( string or symbol; default: :title) - name column with unique elements in table
   >* :through( boolean; default: false) - if you use has_many :through

   `acts_has_many_for` options:
   >* list necessary relations

  `has_many_update` options:
   >*   data: data for update

   `has_many_through_update` options:
   >* :update - array data, data include :id record for update
   >* :new    - array data for new record

  `<relation>_attributes` options:
  >* data - Hash (other data use standart way)

  `<relation>_collection` options:
  >* data - Array (Records, Hash, Empty)

  additionl
  >* `depend_relations` - show depend relations(Array)
  >* `actual?`  - check actuality(Boolean)
  >* `compare`  - return compare column(String)
  >* `destroy!` - standart destroy
  >* `destroy`  - destroy with cheking actuality record

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
