ActiveRecord::Base.configurations = YAML::load( IO.read( File.dirname(__FILE__) + '/../spec/database.yml' ) )
ActiveRecord::Base.establish_connection( 'test' )

ActiveRecord::Schema.define :version => 1 do
  create_table "users", :force => true do |t|
    t.string   "name",       :limit => 50
    t.string   "address_street", :limit => 255
    t.string   "address_city", :limit => 50
    t.string   "address_state_or_province", :limit => 50
    t.string   "address_zip_code", :limit => 9
    t.string   "address_country", :limit => 50
  end

  create_table "people", :force => true do |t|
    t.string   "name",       :limit => 50
  end

  create_table "contact_addresses", :force => true do |t|
    t.integer  :person_id
    t.string   :location, :default => 'unknown', :null => false
    t.string   "address_raw_street", :limit => 255
    t.string   "address_city", :limit => 50
    t.string   "address_state_or_province", :limit => 50
    t.string   "address_raw_zip_code", :limit => 9
    t.string   "address_country", :limit => 50
  end
end

class User < ActiveRecord::Base
  address :address
end

class Person < ActiveRecord::Base
  has_many :contact_addresses
end

class ContactAddress < ActiveRecord::Base
  address :address
  belongs_to :person
end

ADDRESS_ATTRIBUTES = {:raw_street => '123 Jones Street###Suite 540', :city => 'Atlanta', :state_or_province => 'GA',
  :raw_zip_code => '312347890', :country => 'United States' }
