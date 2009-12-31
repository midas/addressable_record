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
      @user = User.new( :name => 'John Smith', :home_address => AddressableRecord::Address.new( @address_attributes ) )
      @user.save!
    end
    
    it "should respond to home_address" do
      @user.respond_to?( :home_address ).should be_true
    end
  end
end
