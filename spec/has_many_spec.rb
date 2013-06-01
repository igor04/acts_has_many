require 'helper'
require 'has_many_common'

describe "acts_has_many clear initialization" do
  before(:each) do
    Object.send :remove_const, :Location if defined? Location
    class Location < ActiveRecord::Base
      self.table_name = 'locations'
      has_many :experiences

      acts_has_many
    end
  end
  it_behaves_like 'acts_has_many'
end

describe "acts_has_many ititialize with relation" do
  before(:each) do
    Object.send :remove_const, :Location if defined? Location

    class Location < ActiveRecord::Base
      self.table_name = 'locations'
      has_many :experiences

      acts_has_many :experiences
    end
  end
  it_behaves_like 'acts_has_many'
end

describe "acts_has_many initialize with :compare" do
  before(:each) do
    Object.send :remove_const, :Location if defined? Location

    class Location < ActiveRecord::Base
      self.table_name = 'locations'
      has_many :experiences

      acts_has_many compare: :title
    end
  end
  it_behaves_like 'acts_has_many'
end

describe "acts_has_many initialize with block" do
  before(:each) do
    Object.send :remove_const, :Location if defined? Location

    class Location < ActiveRecord::Base
      self.table_name = 'locations'
      has_many :experiences

      acts_has_many do |data|
        where arel_table[:title].eq(data[:title])
      end
    end
  end
  it_behaves_like 'acts_has_many'

  it 'condition' do
    where = Location.condition(:title => "ukraine")
    expect(where).to eq Location.where(Location.arel_table[:title].eq("ukraine"))
  end
end
