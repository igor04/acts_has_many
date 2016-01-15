shared_examples_for 'acts_has_many' do
  context 'update method' do
    let(:location){Location.create :title => "italy"}
    let(:experience){Experience.create :location => location, :title => "test experience1"}
    before :each do
      Location.delete_all
      Experience.delete_all
    end

    it 'has_many_update data' do
      add_loc, del_loc = experience.location.has_many_update({"title" => "ukraine"})

      expect(Location.all.size).to be 1
      expect(location).to eq add_loc
      expect(del_loc).to be nil
      expect(experience.location.title).to eq "ukraine"

      Experience.create :location => location, :title => "test experience2"

      add_loc, del_loc = experience.location.has_many_update({"title" => "italy"})

      expect(Location.all.size).to be 2
      expect(location).not_to eq add_loc
      expect(del_loc).to be nil

      experience.location = Location.find(add_loc.id)
      expect(experience.location.title).to eq "italy"

      add_loc, del_loc = experience.location.has_many_update({"title" => "ukraine"})

      expect(location).to eq add_loc
      expect(experience.location).to eq del_loc
    end

    it "parent.child_attributes= Hash" do
      experience = Experience.create location_attributes: {title: "ukraine"}, title: "test experience2"

      expect(Location.all.size).to be 1
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
    Location.all.size.should == 0
  end

  it 'destroy' do
    Location.delete_all
    Experience.delete_all

    location = Location.create(:title => "ukraine")

    Experience.create( :location => location, :title => "test" )

    location.destroy!
    Location.all.size.should == 0
  end

  it 'actual?' do
    Location.delete_all

    location = Location.create(:title => "ukraine")

    location.actual?.should == false
    location.actual?(false).should == false

    Experience.create( :title => 'test', :location => location )

    location.actual?.should == false
    location.actual?(false).should == true

    Experience.create( :title => 'test', :location => location )

    location.actual?.should == true
    location.actual?(false).should == true
  end

  it 'dependent_relations' do
    Location.dependent_relations.should == ['experiences']
  end

  it 'condition' do
    where = Location.condition(:title => "ukraine")
    expect(where).to eq Location.where(:title => "ukraine")
  end
end
