$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'active_record'
#require 'geographer'
require 'addressable_record'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end

ActiveRecord::Base.configurations = YAML::load( IO.read( File.dirname(__FILE__) + '/database.yml' ) )
ActiveRecord::Base.establish_connection( 'test' )

ActiveRecord::Schema.define :version => 1 do
  create_table "users", :force => true do |t|
    t.string   "name",       :limit => 50
    t.string   "home_address_street", :limit => 255
    t.string   "home_address_city", :limit => 50
    t.string   "home_address_state_or_province", :limit => 50
    t.string   "home_address_zip_code", :limit => 9
    t.string   "home_address_country", :limit => 50
  end
end

class User < ActiveRecord::Base
  address :home_address
end

ADDRESS_ATTRIBUTES = {:raw_street => '123 Jones Street###Suite 540', :city => 'Atlanta', :state_or_province => 'GA', 
  :raw_zip_code => '312347890', :country => 'United States' }
