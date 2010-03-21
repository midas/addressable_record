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

    it "should agree that the zip_code is 31234-7890" do
      @user.address.zip_code.should eql( '31234-7890' )
    end

    it "should agree that the country is United States" do
      @user.address.country.should eql( 'United States' )
    end
    
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

      it "should agree that the zip_code is 31234-7890" do
        @user.address.zip_code.should eql( '31234-7890' )
      end

      it "should agree that the country is United States" do
        @user.address.country.should eql( 'United States' )
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

      it "should agree that the address zip code is 31234-7890" do
        @address.zip_code.should eql( '31234-7890' )
      end

      it "should agree that the associated zip code is 31234-7890" do
        @person.contact_addresses.first.address.zip_code.should eql( '31234-7890' )
      end

      it "should agree that the address country is United States" do
        @address.country.should eql( 'United States' )
      end

      it "should agree that the associated country is United States" do
        @person.contact_addresses.first.address.country.should eql( 'United States' )
      end
    end
  end
end
