require 'helper'

(1..3).each do |c|

  case c
  when 1
    class Location < ActiveRecord::Base
      self.table_name = 'locations'
      has_many :experiences
      validates :title, :presence =>  true
        
      acts_has_many
    end
  
  when 2
    class Location < ActiveRecord::Base
      self.table_name = 'locations'
      acts_has_many relations: [:experiences], compare: :title

      has_many :experiences
      validates :title, :presence =>  true
    end
  
  when 3
    class Location < ActiveRecord::Base
      self.table_name = 'locations'
      acts_has_many relations: ['experiences'], compare: 'title'

      has_many :experiences
      validates :title, :presence =>  true
    end
  end

  describe "Initialization tipe #{c}" do
    describe 'acts_has_many' do
      context 'update method' do
        let(:location){Location.create :title => "italy"}
        let(:experience){Experience.create :location => location, :title => "test experience1"}
        before :each do
          Location.delete_all
          Experience.delete_all
        end

        it 'has_many_update(data: data, relation: relation)' do
          add_loc, del_loc = experience.location.has_many_update(
              :data => {"title" => "ukraine"}, :relation => "experiences")
          
          Location.all.size.should == 1
          location.id.should == add_loc
          del_loc.should == nil
          experience.location.title.should == "ukraine"
          
          Experience.create :location => location, :title => "test experience2" 
              
          add_loc, del_loc = experience.location.has_many_update({"title" => "italy"}, "experiences")
          
          Location.all.size.should == 2
          location.id.should_not == add_loc
          del_loc.should == nil
          experience.location = Location.find(add_loc)
          experience.location.title.should == "italy"
          
          add_loc, del_loc = experience.location.has_many_update({"title" => "ukraine"})
          
          location.id.should == add_loc
          experience.location.id.should == del_loc
        end
      
        it 'has_many_update!(data)' do
          # update independent Location
          new_row = experience.location.has_many_update!({"title" => "ukraine"})
          
          Location.all.size.should == 1
          location.id.should == new_row.id
          experience.location.title.should == "ukraine"
          
          Experience.create :location => location, :title => "test experience2" 

          # don't update and create new Location
          new_row = experience.location.has_many_update!({"title" => "italy"})

          experience.reload
          Location.all.size.should == 2
          location.id.should_not == new_row.id
          experience.location.title.should == "italy"
          
          # delete unnecessary Location
          new_row = experience.location.has_many_update!({"title" => "ukraine"})

          location.id.should == new_row.id
          Location.all.size.should == 1
        end
      
        it 'has_many_update!(data, parent_row)' do
          # update independent Location
          new_row = location.has_many_update!({"title" => "ukraine"}, experience)
          
          Location.all.size.should == 1
          location.id.should == new_row.id
          experience.location.title.should == "ukraine"
          
          Experience.create :location => location, :title => "test experience2" 

          # don't update and create new Location
          new_row = location.has_many_update!({"title" => "italy"}, experience)

          experience.reload
          Location.all.size.should == 2
          location.id.should_not == new_row.id
          experience.location.title.should == "italy"
          
          # delete unnecessary Location
          new_row = location.has_many_update!({"title" => "italy"}, Experience.where(location_id: location).first) #becaus experience wos reload

          location.id.should_not == new_row.id
          location.frozen?.should == true
          Location.all.size.should == 1
        end

        it 'update_with_<relation>(data)' do
          add_loc, del_loc = experience.location.update_with_experiences({"title" => "ukraine"})
          
          Location.all.size.should == 1
          location.id.should == add_loc
          del_loc.should == nil
          experience.location.title.should == "ukraine"
          
          Experience.create :location => location, :title => "test experience2" 
              
          add_loc, del_loc = experience.location.update_with_experiences({"title" => "italy"})
          
          Location.all.size.should == 2
          location.id.should_not == add_loc
          del_loc.should == nil
          experience.location = Location.find(add_loc)
          experience.location.title.should == "italy"
          
          add_loc, del_loc = experience.location.update_with_experiences({"title" => "ukraine"})
          
          location.id.should == add_loc
          experience.location.id.should == del_loc
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
        location.actuale?(:relation => "experiences").should == false

        Experience.create( :title => 'test', :location => location )

        location.actuale?.should == true
        location.actuale?(:relation => "experiences").should == false
        location.actuale?(:relation => :experiences).should == false
        location.actuale?(:relation => "Experience").should == false
        location.actuale?("Experience").should == false

        Experience.create( :title => 'test', :location => location )
        
        location.actuale?.should == true
        location.actuale?(:relation => "experiences").should == true
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
  end
end