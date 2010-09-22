require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "AddressableRecord" do
  describe "having ActiveRecord extensions" do
    it "should respond to address" do
      ActiveRecord::Base.respond_to?( :address ).should be_true
    end

    it "should respond to addresses" do
      ActiveRecord::Base.respond_to?( :addresses ).should be_true
    end
  end

  describe "having models descending from ActiveRecord" do
    before :each do
      @address_attributes = ADDRESS_ATTRIBUTES
      @user = User.new( :name => 'John Smith', :address => AddressableRecord::Address.new( @address_attributes ) )
      @user.save!
    end

    it "should respond to address" do
      @user.respond_to?( :address ).should be_true
    end

    it "should be an AddressableRecord::Address" do
      @user.address.is_a?( AddressableRecord::Address ).should be_true
    end

    it "should agree that the size of streets is 2" do
      @user.address.streets.size.should eql( 2 )
    end

    it "should agree that the street address is 123 Jones Street, Suite 540" do
      @user.address.street.should eql( '123 Jones Street, Suite 540' )
    end

    it "should agree that the city is Atlanta" do
      @user.address.city.should eql( 'Atlanta' )
    end

    it "should agree that the state is GA" do
      @user.address.state.should eql( 'GA' )
    end

    it "should agree that the zip_code is 33333-1111" do
      @user.address.zip_code.should eql( '33333-1111' )
    end

    it "should agree that the country is U.S.A." do
      @user.address.country.should eql( 'U.S.A.' )
    end

    # describe "when creating with a string of address elements" do
    #   before :each do
    #     attributes = ADDRESS_ATTRIBUTES
    #     @address_attributes =
    #       [attributes[:raw_street],attributes[:city],attributes[:state_or_province],attributes[:raw_zip_code],attributes[:country]]
    #     @klass = AddressableRecord::Address
    #     @instance = AddressableRecord::Address.new( @address_attributes.join( ', ' ) )
    #   end
    #
    #   it "should create an address record" do
    #     @instance.is_a?( @klass ).should be_true
    #   end
    # end

    describe "when creating with a Hash of address elements" do
      before :each do
        @user = User.new( :name => 'John Smith', :address => @address_attributes )
        @user.save!
      end

      it "should respond to address" do
        @user.respond_to?( :address ).should be_true
      end

      it "should be an AddressableRecord::Address" do
        @user.address.is_a?( AddressableRecord::Address ).should be_true
      end

      it "should agree that the size of streets is 2" do
        @user.address.streets.size.should eql( 2 )
      end

      it "should agree that the street address is 123 Jones Street, Suite 540" do
        @user.address.street.should eql( '123 Jones Street, Suite 540' )
      end

      it "should agree that the city is Atlanta" do
        @user.address.city.should eql( 'Atlanta' )
      end

      it "should agree that the state is GA" do
        @user.address.state.should eql( 'GA' )
      end

      it "should agree that the zip_code is 33333-1111" do
        @user.address.zip_code.should eql( '33333-1111' )
      end

      it "should agree that the country is U.S.A." do
        @user.address.country.should eql( 'U.S.A.' )
      end

      it "should handle a 5 digit zip code" do
        @user = User.new( :name => 'John Smith', :address => @address_attributes.merge( :raw_zip_code => '31234' ) )
        @user.save!
        @user.address.zip_code.should eql( '31234' )
      end
    end
  end

  describe "when used through an association" do
    before :each do
      @address_attributes = ADDRESS_ATTRIBUTES
      @person = Person.new( :name => 'John Smith' )
      @person.save!
    end

    describe "creating through the association" do
      before :each do
        @address = AddressableRecord::Address.new( @address_attributes )
        @person.contact_addresses.build( :address => @address )
        @person.save!
      end

      it "should agree that the address street is 123 Jones Street, Suite 540" do
        @address.street.should eql( '123 Jones Street, Suite 540' )
      end

      it "should agree that the associated street is 123 Jones Street, Suite 540" do
        @person.contact_addresses.first.address.street.should eql( '123 Jones Street, Suite 540' )
      end

      it "should agree that the address city is Atlanta" do
        @address.city.should eql( 'Atlanta' )
      end

      it "should agree that the associated street is Atlanta" do
        @person.contact_addresses.first.address.city.should eql( 'Atlanta' )
      end

      it "should agree that the address state is GA" do
        @address.state.should eql( 'GA' )
      end

      it "should agree that the associated state is GA" do
        @person.contact_addresses.first.address.state.should eql( 'GA' )
      end

      it "should agree that the address zip code is 33333-1111" do
        @address.zip_code.should eql( '33333-1111' )
      end

      it "should agree that the associated zip code is 33333-1111" do
        @person.contact_addresses.first.address.zip_code.should eql( '33333-1111' )
      end

      it "should agree that the address country is U.S.A." do
        @address.country.should eql( 'U.S.A.' )
      end

      it "should agree that the associated country is U.S.A." do
        @person.contact_addresses.first.address.country.should eql( 'U.S.A.' )
      end
    end
  end
end
