require File.expand_path( File.dirname(__FILE__) + '/../spec_helper' )
require File.expand_path( File.dirname(__FILE__) + '/address_parsing_shared_spec' )

describe "AddressableRecord::Address" do
  before :each do
    @address_attributes = ADDRESS_ATTRIBUTES
    @klass = AddressableRecord::Address
    @instance = AddressableRecord::Address.new( @address_attributes )
  end
  
  it "should agree that the raw_street is correct" do
    @instance.send( :raw_street ).should eql( @address_attributes[:raw_street] )
  end
  
  it "should agree that the city is correct" do
    @instance.city.should eql( @address_attributes[:city] )
  end
  
  it "should agree that the state_or_province is correct" do
    @instance.state_or_province.should eql( @address_attributes[:state_or_province] )
  end
  
  it "should agree that the raw_zip_code is correct" do
    @instance.send( :raw_zip_code ).should eql( @address_attributes[:raw_zip_code] )
  end
  
  it "should agree that the country is correct" do
    @instance.country.should eql( @address_attributes[:country] )
  end
  
  it "should agree that the streets array is the correct size" do
    @instance.streets.size.should eql( 2 )
  end
  
  it "should agree that the default call to \#street is correct" do
    @instance.street.should eql( @address_attributes[:raw_street].split( AddressableRecord::Address.street_delimiter ).join( ', ' ) )
  end
  
  it "should agree that the call to \#street with a pattern of '\\n' is correct" do
    @instance.street( '\n' ).should eql( @address_attributes[:raw_street].split( AddressableRecord::Address.street_delimiter ).join( '\n' ) )
  end
  
  it "should agree that the zip code is correct" do
    @instance.zip_code.should eql( "#{@address_attributes[:raw_zip_code][0..4]}-#{@address_attributes[:raw_zip_code][5..9]}")
  end
  
  it "should agree that the state is the state_or_province" do
    @instance.state.should eql( @instance.state_or_province )
  end
  
  it "should agree that the province is the state_or_province" do
    @instance.province.should eql( @instance.state_or_province )
  end
  
  it "should be able to find the position of a state abbreviation in an array" do
    @klass.send( :find_state_position, ['123 Jones St.', 'Atlanta', 'GA', '33333', ] ).should eql( 2 )
  end

  it "should be able to find the position of a state name in an array" do
    @klass.send( :find_state_position, ['123 Jones St.', 'Atlanta', 'Georgia', '33333', ] ).should eql( 2 )
  end

  it "should return nil if an address array does not have a state in it" do
    @klass.send( :find_state_position, ['123 Jones St.', 'Atlanta', '33333' ] ).should be_nil
  end

  describe "when parsing an hash of address elements" do
    
  end
  
  describe "when parsing an array of address elements" do
    before :each do
      @address_elements_without_country = ['123 Jones Street', 'Suite 540', 'Atlanta', 'GA', '33333-1111']
    end

    describe "with a country" do
      before :each do
        @address = @klass.parse( @address_elements_without_country + ['United States'] )
      end

      it_should_behave_like "The address 123 Jones Street, Suite 540, Atlanta, GA, 33333-1111, United States"
    end

    describe "without a country" do
      before :each do
        @address = @klass.parse( @address_elements_without_country )
      end

      it_should_behave_like "The address 123 Jones Street, Suite 540, Atlanta, GA, 33333-1111, United States"
    end

    describe "with a spelled out state name" do
      before :each do
        @address_elements_without_country[@address_elements_without_country.index( 'GA' )] = 'Georgia'
        @address = @klass.parse( @address_elements_without_country )
      end

      it_should_behave_like "The address 123 Jones Street, Suite 540, Atlanta, GA, 33333-1111, United States"
    end

    describe "when printing out a formatted string" do
      before :each do
        @address = @klass.parse( @address_elements_without_country )
      end
      
      it "should obey the :us format correctly" do
        @address.to_s( :us ).should eql( '123 Jones Street, Suite 540, Atlanta GA, 33333-1111' )
      end

      it "should obey the :us_long format correctly" do
        @address.to_s( :us_long ).should eql( '123 Jones Street, Suite 540, Atlanta GA, 33333-1111, United States' )
      end

      it "should obey the %s format correctly" do
        @address.to_s( '%s' ).should eql( '123 Jones Street, Suite 540' )
      end

      it "should obey the %1 format correctly" do
        @address.to_s( '%1' ).should eql( '123 Jones Street' )
      end

      it "should obey the %2 format correctly" do
        @address.to_s( '%2' ).should eql( 'Suite 540' )
      end

      it "should obey the %3 format correctly" do
        @address.to_s( '%3' ).should eql( '' )
      end

      it "should obey the %4 format correctly" do
        @address.to_s( '%4' ).should eql( '' )
      end

      it "should obey the %5 format correctly" do
        @address.to_s( '%5' ).should eql( '' )
      end

      it "should obey the %c format correctly" do
        @address.to_s( '%c' ).should eql( 'Atlanta' )
      end

      it "should obey the %S format correctly" do
        @address.to_s( '%S' ).should eql( 'GA' )
      end

      it "should obey the %z format correctly" do
        @address.to_s( '%z' ).should eql( '33333-1111' )
      end

      it "should obey the %C format correctly" do
        @address.to_s( '%C' ).should eql( 'United States' )
      end
    end
  end
end