# acts_has_many [![Build Status](https://travis-ci.org/igor04/acts_has_many.png?branch=master)](https://travis-ci.org/igor04/acts_has_many)

Acts_has_many gem gives functional for clean update elements `has_many` relation
(additional is `has_many :trhough`). The aim is work with has_many relation without gerbage,
every record must be used, othervise there will be no record.

## Installation

Add this line to your application's Gemfile:

    gem 'acts_has_many'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install acts_has_many

## Usage
1. To initialize gem you can use `acts_has_many` only, or `acts_has_many` with `acts_has_many_for` together
2. In model where you set `acts_has_many` will work clearly (all records used, no duplications)
3. Should use `dependent: :destroy`

4. If only `acts_has_many` is used:
```ruby
    class Posting < ActiveRecord::Base
      belongs_to :tag, dependent: :destroy
    end

    class Tag < ActiveRecord::Base
      has_many :postings

      acts_has_many :postings
    end
```
    In this case you have `has_many_update` method:
```ruby
    new_record, delete_record =  Tag.first.has_many_update {title: 'ruby'}
```
    if you use `acts_has_many` with `through: true` parameters:
```ruby
    new_records, delete_ids = Tag.has_many_through_update(update: data, new: date)
```

5. If you use `acts_has_many` with `acts_has_many_for`
```ruby
    class Posting < ActiveRecord::Base
      belongs_to :tag, dependent: :destroy

      acts_has_many_for :tag
    end

    class Tag < ActiveRecord::Base
      has_many :postings

      acts_has_many :postings
    end
```
    In this case you can use the same that is in 4-th point and also:
```ruby
    Posting.first.tag_attributes = {title: 'ruby'}
```
    if you use `acts_has_many` with `through: true` parameters
```ruby
    Posting.first.tags_collection = [{title: 'ruby'}, {title: 'python'}]
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

  Additional
  >* `depend_relations` - show depend relations(Array)
  >* `actual?`  - check actuality(Boolean)
  >* `compare`  - return compare column(String)
  >* `destroy!` - standart destroy
  >* `destroy`  - destroy with cheking actuality record

Examples
--------
Use with `has_manay`:
```ruby
  class Posting < ActiveRecord::Base
    belongs_to :tag, dependent: :destroy

    acts_has_many_for :tag
  end

  class Tag < ActiveRecord::Base
    has_many :postings

    acts_has_many :postings, compare: :name
  end

  posting = Posting.create title: 'First posting',
                           tag_attributes: {name: 'ruby'}

  posting.tag # => #<Tag id: 1, title: "ruby">
  Tag.all # => [#<Tag id: 1, title: "ruby">]

  posting = Posting.create title: 'Second posting',
                           tag_attributes: {name: 'ruby'}

  posting.tag # => #<Tag id: 1, title: "ruby">
  Tag.all # => [#<Tag id: 1, title: "ruby">]

  posting.update_attributes tag_attributes: {name: 'python'}

  posting.tag # => #<Tag id: 2, title: "python">
  Tag.all # => [#<Tag id: 1, title: "ruby">, #<Tag id: 2, title: "python">]

  posting.tag_attributes = Tag.first
  posting.save

  Tag.all # => [#<Tag id: 1, title: "ruby">]
```
Use with `has_many :through`
```ruby
  class Posting < ActiveRecord::Base
    has_many :posting_tags, dependent: :destroy
    has_many :tags, through: :posting_tags

    acts_has_many_for :tags
  end

  class PostingTag < ActiveRecord::Base
    belongs_to :posting
    belongs_to :tag
  end

  class Tag < ActiveRecord::Base
    has_many :postings, through: :posting_tags
    has_many :posting_tags

    acts_has_many :postings, through: true
  end

  posting = Posting.create title: 'First posting',
                           tags_collection: [{name: 'ruby'}, {name: 'python'}]

  posting.tags
  # => [#<Tag id: 1, title: "ruby">, #<Tag id: 2, title: "python">]
  Tag.all
  # => [#<Tag id: 1, title: "ruby">, #<Tag id: 2, title: "python">]

  posting = Posting.create title: 'Second posting',
                           tags_collection: [{name: 'ruby'}, {name: 'java'}]

  posting.tags
  # => [#<Tag id: 1, title: "ruby">, #<Tag id: 3, title: "java">]
  Tag.all
  # => [#<Tag id: 1, title: "ruby">, #<Tag id: 2, title: "python">, #<Tag id: 3, title: "java">]

  posting.update_attributes tags_collection: [Tag.first]

  posting.tags # => [#<Tag id: 2, title: "ruby">]
  Tag.all
  # => [#<Tag id: 1, title: "ruby">, #<Tag id: 2, title: "python">]

  Posting.first.destroy

  Tag.all # => [#<Tag id: 1, title: "ruby">]
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
