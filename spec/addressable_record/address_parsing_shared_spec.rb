require File.expand_path( File.dirname(__FILE__) + '/../spec_helper' )

shared_examples_for "The address 123 Jones Street, Suite 540, Atlanta, GA, 33333-1111, United States" do
  it "should be an AddressableRecord::Address" do
    @address.is_a?( AddressableRecord::Address ).should be_true
  end

  it "should agree that the size of streets is 2" do
    @address.streets.size.should eql( 2 )
  end

  it "should agree that the street address is 123 Jones Street, Suite 540" do
    @address.street.should eql( '123 Jones Street, Suite 540' )
  end

  it "should agree that the city is Atlanta" do
    @address.city.should eql( 'Atlanta' )
  end

  it "should agree that the state is GA" do
    @address.state.should eql( 'GA' )
  end

  it "should agree that the zip_code is 33333-1111" do
    @address.zip_code.should eql( '33333-1111' )
  end

  it "should agree that the country is United States" do
    @address.country.should eql( 'United States' )
  end
end