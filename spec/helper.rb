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
end

class Experience < ActiveRecord::Base
  self.table_name = 'experiences'
  belongs_to :location, :dependent => :destroy
end

class Location < ActiveRecord::Base
  self.table_name = 'locations'
  has_many :experiences
  validates :title, :presence =>  true
  
  acts_has_many
end
