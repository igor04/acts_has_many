require 'rubygems'
require 'active_record'
require 'bundler'
require "#{File.dirname(__FILE__)}/../init"

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Schema.verbose = false

ActiveRecord::Base.connection.schema_cache.clear!
ActiveRecord::Schema.define(:version => 1) do
  create_table :experiences do |t|
    t.string :title
    t.references :location
  end  
  create_table :locations do |t|
    t.string :title
  end    
  
  create_table :locals do |t|
    t.string :title
  end    
  create_table :company_locals do |t|
    t.references :local
    t.references :company
  end    
  create_table :companies do |t|
    t.string :title
  end    
end

class Experience < ActiveRecord::Base
  self.table_name = 'experiences'
  belongs_to :location, :dependent => :destroy

  acts_has_many_for :location
end

class CompanyLocal < ActiveRecord::Base
  self.table_name = 'company_locals'
  belongs_to :local
  belongs_to :company
end

class Company < ActiveRecord::Base
  self.table_name = 'companies'
  has_many :company_locals, :dependent => :destroy
  has_many :locals, :through => :company_locals
end
