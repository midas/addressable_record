module AddressableRecord
  class Address
    attr_reader :raw_street, :street, :city, :state_or_province, :raw_zip_code, :zip_code, :country
    
    def initialize( raw_street, city, state_or_province, raw_zip_code, country )
      @raw_street, @city, @state_or_province, @raw_zip_code, @country = raw_street, city, state_or_province, raw_zip_code, country
      
      self.freeze
    end
    
  end
end