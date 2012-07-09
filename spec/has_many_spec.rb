require 'helper'

describe 'acts_has_many' do
  it 'update' do
    location = Location.create :title => "italy"
    experience = Experience.create :location => location, :title => "test experience1"
            
    add_loc, del_loc = experience.location.has_many_update(
        :data => {"title" => "ukraine"}, :relation => "experiences")
    location = Location.find(add_loc)
    experience.location = location
    Location.delete(del_loc) unless del_loc.nil?
    
    experience.location.title.should == "ukraine"
    Location.all.size.should == 1
    
    Experience.create :location => location, :title => "test experience2" 
        
    add_loc, del_loc = experience.location.has_many_update(
        :data => {"title" => "italy"}, :relation => "experiences")
    experience.location = Location.find(add_loc)
    Location.delete(del_loc) unless del_loc.nil?
    
    experience.location.id.should == add_loc
    Location.all.size.should == 2
    
    add_loc, del_loc = experience.location.has_many_update(
        :data => {"title" => "ukraine"}, :relation => "experiences")
    experience.location = Location.find(add_loc)
    Location.delete(del_loc) unless del_loc.nil?
    
    experience.location.should == location
    Location.all.size.should == 1
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
    location.actuale?(:relation => "experiences").should == false
    
    Experience.create( :title => 'test', :location => location )

    location.actuale?.should == true
    location.actuale?(:relation => "experiences").should == false

    Experience.create( :title => 'test', :location => location )
    
    location.actuale?.should == true
    location.actuale?(:relation => "experiences").should == true
  end 
end