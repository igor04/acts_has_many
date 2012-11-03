require 'helper'

class Location < ActiveRecord::Base
  self.table_name = 'locations'
  has_many :experiences

  acts_has_many :experiences, compare: 'title'
end

describe 'acts_has_many' do
  context 'update method' do
    let(:location){Location.create :title => "italy"}
    let(:experience){Experience.create :location => location, :title => "test experience1"}
    before :each do
      Location.delete_all
      Experience.delete_all
    end

    it 'has_many_update data, relation' do
      add_loc, del_loc = experience.location.has_many_update({"title" => "ukraine"}, "experiences")

      expect(Location.all.size).to be 1
      expect(location).to eq add_loc
      expect(del_loc).to be nil
      expect(experience.location.title).to eq "ukraine"

      Experience.create :location => location, :title => "test experience2" 

      add_loc, del_loc = experience.location.has_many_update({"title" => "italy"}, "experiences")

      expect(Location.all.size).to be 2
      expect(location).not_to eq add_loc
      expect(del_loc).to be nil

      experience.location = Location.find(add_loc)
      expect(experience.location.title).to eq "italy"

      add_loc, del_loc = experience.location.has_many_update({"title" => "ukraine"}, :experiences)

      expect(location).to eq add_loc
      expect(experience.location).to eq del_loc
    end

    it 'update_with_<relation> data' do
      add_loc, del_loc = experience.location.update_with_experiences({"title" => "ukraine"})

      expect(Location.all.size).to be 1
      expect(location).to eq add_loc
      expect(del_loc).to be nil
      expect(experience.location.title).to eq "ukraine"

      Experience.create :location => location, :title => "test experience2" 

      add_loc, del_loc = experience.location.update_with_experiences({"title" => "italy"})

      expect(Location.all.size).to be 2
      expect(location.id).not_to eq add_loc
      expect(del_loc).to be nil

      experience.location = Location.find(add_loc)
      expect(experience.location.title).to eq "italy"

      add_loc, del_loc = experience.location.update_with_experiences({"title" => "ukraine"})

      expect(location).to eq add_loc
      expect(experience.location).to eq del_loc
    end

    it "parent.child_attributes= Hash" do
      experience = Experience.create location_attributes: {title: "ukraine"}, title: "test experience2"

      Location.all.size.should be 1
      experience.location.title.should eq "ukraine"

      Experience.create location_attributes: {title: "ukraine"}, title: "test experience2"
      Location.all.size.should be 1

      experience.location_attributes = {"title" => "italy"}
      experience.save

      Location.all.size.should be 2
      experience.location.title.should eq "italy"

      experience.location_attributes = {"title" => "ukraine"}
      experience.save

      Location.all.size.should be 1
      experience.location.title.should eq "ukraine"
    end

    it "parent.child_attributes= exist_record" do
      experience = Experience.create location_attributes: {title: "ukraine"}, title: "test experience2"

      Location.all.size.should be 1
      experience.location.title.should eq "ukraine"

      Experience.create location_attributes: Location.first, title: "test experience2"
      Location.all.size.should be 1

      experience.location_attributes = {"title" => "italy"}
      experience.save

      Location.all.size.should be 2
      experience.location.title.should eq "italy"

      experience.location_attributes = Location.first
      experience.save

      Location.all.size.should be 1
      experience.location.title.should eq "ukraine"
    end
  end

  it 'destroy' do
    Location.delete_all
    Experience.delete_all

    location = Location.create(:title => "ukraine")

    Experience.create( :location => location, :title => "test" )

    location.destroy
    Location.all.size.should == 1

    Experience.all[0].destroy
    location.destroy
    Location.all.size.should == 0
  end  

  it 'actuale?' do
    Location.delete_all

    location = Location.create(:title => "ukraine")

    location.actuale?.should == false
    location.actuale?("experiences").should == false

    Experience.create( :title => 'test', :location => location )

    location.actuale?.should == true
    location.actuale?("experiences").should == false
    location.actuale?(:experiences).should == false
    location.actuale?("Experience").should == false
    location.actuale?("Experience").should == false

    Experience.create( :title => 'test', :location => location )

    location.actuale?.should == true
    location.actuale?("experiences").should == true
    location.actuale?(:experiences).should == true
  end 

  it 'compare' do
    Location.compare.should == :title
  end

  it 'model' do
    location = Location.create(:title => "ukraine")
    location.model.should == Location
  end

  it 'dependent_relations' do
    Location.dependent_relations.should == ['experiences']
  end
end
