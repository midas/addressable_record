@person = Person.create( :name => 'John Smith' )
@person.contact_addresses.build( :address => AddressableRecord::Address.new( ADDRESS_ATTRIBUTES ) )
@person.save!