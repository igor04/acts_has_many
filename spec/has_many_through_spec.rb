require 'helper'

(1..3).each do |c|

  case c
  when 1
    class Local < ActiveRecord::Base
      self.table_name = 'locals'
      validates :title, :presence =>  true

      has_many :companies, :through => :company_locals
      acts_has_many :through => true
      has_many :company_locals
    end
  
  when 2
    class Local < ActiveRecord::Base
      self.table_name = 'locals'
      validates :title, :presence =>  true

      has_many :companies, :through => :company_locals
      has_many :company_locals
      acts_has_many through: true, relations: [:companies], compare: :title
    end
  
  when 3
    class Local < ActiveRecord::Base
      self.table_name = 'locals'
      validates :title, :presence =>  true

      has_many :companies, :through => :company_locals
      has_many :company_locals
      acts_has_many :through => true, relations: ['companies'], compare: 'title'
    end
  end

  describe "Initialization tipe #{c}" do
    describe 'acts_has_many with :through' do
      it 'update' do
        Local.delete_all
        
        Local.all.size.should == 0
        
        new_row, del_ids = Local.has_many_through_update( :new => [
          { title: 'test0'},
          { title: 'test1'},
          { title: 'test2'},
          { title: 'test3'},
          { title: 'test0'},
        ], relation: :companies)

        new_row.count.should == 4
        del_ids.should == []
        Local.all.size.should == 4

        new_row1, del_ids1 = Local.has_many_through_update( 
        :new => [
          { title: 'test0'},
          { 'title' => 'test1'}],
        :update => {
          new_row[2].id => {title: 'test2s'},
          new_row[3].id.to_s => {'title' => 'test3s'}
        }, relation: 'companies')

        new_row1[0].id.should == new_row[0].id
        new_row1[1].id.should == new_row[1].id
        new_row1[2].id.should == new_row[2].id
        new_row1[3].id.should == new_row[3].id
        del_ids1.should == []
        Local.find(new_row[2].id).title.should == 'test2s'
        Local.find(new_row[3].id).title.should == 'test3s'
        Local.all.size.should == 4


        new_row, del_ids = Local.has_many_through_update( 
        :new => [
          { title: 'test0'},
          { title: 'test3s'}],
        :update => {
          new_row1[2].id => {title: 'test2s'},
          new_row1[3].id => {title: ''}
        }, relation: :companies)

        del_ids.should == []
        new_row.size.should == 3

        new_row, del_ids = Local.has_many_through_update( 
        :update => {
          new_row1[2].id => {title: 'test2s'},
          new_row1[3].id => {title: ''}
        }, relation: :companies)

        del_ids.should == [new_row1[3].id]
        new_row.size.should == 1

        new_row, del_ids = Local.has_many_through_update( 
        :new => [{ title: 'test0'}],
        :update => { new_row1[2].id => {title: 'test0'} }, relation: :companies)

        new_row.size.should == 1

        Local.all.size.should == 4
      end
    end
  end
end