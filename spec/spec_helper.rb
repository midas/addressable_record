$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'active_record'
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
    t.string   "home_street", :limit => 255
    t.string   "home_city", :limit => 50
    t.string   "home_state_or_province", :limit => 2
    t.string   "home_zip", :limit => 9
    t.string   "home_country", :limit => 50
  end
end

class User < ActiveRecord::Base
  address :home_address
end
