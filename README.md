# acts_has_many [![Build Status](https://travis-ci.org/igor04/acts_has_many.png?branch=master)](https://travis-ci.org/igor04/acts_has_many)

Acts_has_many gem gives functional for useing common resources with `has_many` relation
or `has_many :trhough`. The aim is common using records with has_many relation without duplications
and gerbage, every erecord will be used

## Installation

Add this line to your application's Gemfile:

    gem 'acts_has_many'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install acts_has_many

## Usage
1. To initialize gem you should add `acts_has_many` to your common resource model

  ```ruby
      class Tag < ActiveRecord::Base
        has_many :postings

        acts_has_many :postings
      end
  ```

2. And add `acts_has_many_for` to model which will use common resource like:


  ```ruby
      class Posting < ActiveRecord::Base
        belongs_to :tag, dependent: :destroy

        acts_has_many_for :tag
      end
  ```

3. Then you could use new functionality

  ```ruby
      Posting.first.tag_attributes = {title: 'ruby'}
  ```

  in case with relation `has_many through` you could write next:

  ```ruby
      Posting.first.tags_collection = [{title: 'ruby'}, {title: 'python'}]
  ```

New in v0.3.2
--------------

Use `block` to change condition, default search is `where :compare => :value`

```ruby
  class Tag < ActiveRecord::Base
    has_many :postings

    acts_has_many :postings   end
```

Replace `compare` method to `condition`

Notice, if block is defined:
   >* `:compare` argument will be ignored
   >* auto `validates :compare, uniqueness: true` is off


More
----

  `acts_has_many` options:
  >* list relations or after necessary relations
  >* :compare( string or symbol; default: :title) - name column with unique elements in table
  >* :through( boolean; default: false) - if you use has_many :through
  >* &block(should return ActiveRecord::Relation; by default :compare option is used)
  >*   example: do |params| where arel_table[:title].matches(params[:title]) end

  `acts_has_many_for` options:
  >* list necessary relations

  `<relation>_attributes` options:
  >* data - Hash (other data use standart way)

  `<relation>_collection` options:
  >* data - Array (Records, Hash, Empty)

  `has_many_update` options:
   >*   data: data for update

  `has_many_through_update` options:
  >* :update - array data, data include :id record for update
  >* :new    - array data for new record

  Additional
  >* `depend_relations` - show depend relations(Array)
  >* `actual?`  - check actuality(Boolean)
  >* `condition` - call block(in: params, out: ActiveRecord::Relation)
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
  Tag.all     # => [#<Tag id: 1, title: "ruby">]

  posting = Posting.create title: 'Second posting',
                           tag_attributes: {name: 'ruby'}

  #NO DUPLICATIONS
  posting.tag # => #<Tag id: 1, title: "ruby">
  Tag.all     # => [#<Tag id: 1, title: "ruby">]

  posting.update_attributes tag_attributes: {name: 'python'}

  #COORRECT UPDATING
  posting.tag # => #<Tag id: 2, title: "python">
  Tag.all     # => [#<Tag id: 1, title: "ruby">, #<Tag id: 2, title: "python">]

  posting.tag_attributes = Tag.first
  posting.save

  #NO UNUSED RECORDS
  Tag.all     # => [#<Tag id: 1, title: "ruby">]
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

  posting.tags
  # => [#<Tag id: 2, title: "ruby">]
  Tag.all
  # => [#<Tag id: 1, title: "ruby">, #<Tag id: 2, title: "python">]

  Posting.first.destroy

  Tag.all
  # => [#<Tag id: 1, title: "ruby">]
```

Contributing
------------

You can help improve this project.

Here are some ways *you* can contribute:

* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code
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
