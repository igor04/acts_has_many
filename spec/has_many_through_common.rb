shared_examples_for 'acts_has_many through: true' do
  it 'parent.child_colletion=<data>' do
    Local.delete_all

    company = Company.create title: 'test', locals_collection: [{title: 'testx'}]
    company.locals.first.title.should eq 'testx'

    company.locals_collection = [{title: 'test2'}]
    company.locals.first.title.should eq 'test2'
    Local.all.size.should be 2

    company.save # after save we clear garbage
    company.locals.first.title.should eq 'test2'
    Local.all.size.should be 1

    company2 = Company.create title: 'test2', locals_collection: [{title: 'test2'},{title: 'test1'}]
    company.locals_collection = Local.all
    company.locals.size.should be 2

    company.save
    Local.all.size.should be 2

    company.locals_collection = [{title: 'test3'}, {title: 'test2'}]
    company.save

    company.locals.size.should be 2
    Local.all.size.should be 3

    company.locals_collection = [{title: 'test1'}]
    Local.all.size.should be 3

    company.save
    Local.all.size.should be 2

    company2.locals_collection = [Local.last]
    Local.all.size.should be 2

    company2.save
    Local.all.size.should be 1
    company2.locals.should eq company.locals

    company2.locals_collection = []
    company2.save
    company2.locals.should eq []

    company.locals_collection = []
    company.save

    Local.all.should eq []
  end
  it 'update' do
    Local.delete_all

    Local.all.size.should == 0

    new_records, del_records = Local.has_many_through_update( :new => [
      { title: 'test0'},
      { title: 'test1'},
      { title: 'test2'},
      { title: 'test3'},
      { title: 'test0'},
    ])

    expect(new_records.count).to be 4
    expect(del_records).to eq []
    expect(Local.all.size).to be 4

    new_records_1, del_records_1 = Local.has_many_through_update(
    :new => [
      { title: 'test0'},
      { 'title' => 'test1'}
    ],
    :update => {
      new_records[2].id => {title: 'test2s'},
      new_records[3].id.to_s => {'title' => 'test3s'}
    })

    expect(new_records_1.map(&:id).sort!).to eq new_records.map(&:id)
    expect(Local.find(new_records[2].id).title).to eq 'test2s'
    expect(Local.find(new_records[3].id).title).to eq 'test3s'
    expect(Local.all.size).to be 4

    new, del = Local.has_many_through_update(
    :new => [
      { title: 'test0'},
      { title: 'test3s'}],
    :update => {
      new_records_1[0].id => {title: 'test0'},
    })

    expect(del.size).to be 1
    expect(new.size).to be 3
  end
end
