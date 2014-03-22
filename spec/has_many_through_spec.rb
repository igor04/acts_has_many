require 'helper'
require 'has_many_through_common'

describe "acts_has_many :through" do
  before(:each) do
    Object.send :remove_const, :Local if defined? Local

    class Local < ActiveRecord::Base
      self.table_name = 'locals'
      has_many :companies, :through => :company_locals
      has_many :company_locals

      acts_has_many through: true
    end
  end
  it_behaves_like 'acts_has_many through: true'
end

describe "acts_has_many :through with relation" do
  before(:each) do
    Object.send :remove_const, :Local if defined? Local

    class Local < ActiveRecord::Base
      self.table_name = 'locals'
      has_many :companies, :through => :company_locals
      has_many :company_locals

      acts_has_many :companies, through: true
    end
  end
  it_behaves_like 'acts_has_many through: true'
end

describe "acts_has_many :through with  :compare" do
  before(:each) do
    Object.send :remove_const, :Local if defined? Local

    class Local < ActiveRecord::Base
      self.table_name = 'locals'
      has_many :companies, :through => :company_locals
      has_many :company_locals

      acts_has_many compare: :title, through: true
    end
  end
  it_behaves_like 'acts_has_many through: true'
end

describe "acts_has_many :through with relation and :compare" do
  before(:each) do
    Object.send :remove_const, :Local if defined? Local

    class Local < ActiveRecord::Base
      self.table_name = 'locals'
      has_many :companies, :through => :company_locals
      has_many :company_locals

      acts_has_many :companies, compare: :title, through: true
    end
  end
  it_behaves_like 'acts_has_many through: true'
end

describe "acts_has_many :through with relation and block" do
  before(:each) do
    Object.send :remove_const, :Local if defined? Local

    class Local < ActiveRecord::Base
      self.table_name = 'locals'
      has_many :companies, :through => :company_locals
      has_many :company_locals

      acts_has_many :companies, through: true do |local|
        where arel_table[:title].eq local[:title]
      end
    end
  end
  it_behaves_like 'acts_has_many through: true'
end

describe "acts_has_many :through with relation and block" do
  before(:each) do
    Object.send :remove_const, :Local if defined? Local

    class Local < ActiveRecord::Base
      self.table_name = 'locals'
      has_many :companies, :through => :company_locals
      has_many :company_locals

      acts_has_many through: true do |local|
        where arel_table[:title].eq local[:title]
      end
    end
  end
  it_behaves_like 'acts_has_many through: true'
end
