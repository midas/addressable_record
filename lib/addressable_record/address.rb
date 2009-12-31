require File.dirname(__FILE__) + '/states'

module AddressableRecord
  class Address
    attr_reader :raw_street, :streets, :city, :state_or_province, :zip_code, :country
    
    def initialize( attrs )
      raise 'Initilaizer argument must be an attributes hash.' unless attrs.is_a?( Hash )
      @city, @state_or_province, @country = attrs[:city], attrs[:state_or_province], attrs[:country]
      
      @@street_delimiter ||= '###'
      @@zip_code_delimiter ||= '-'
      @streets = AddressableRecord::Address.parse_street( attrs[:raw_street] || '' )
      raw_zip = (attrs[:raw_zip_code] || '')
      @zip_code = raw_zip.size == 5 ? @raw_zip_code : raw_zip.gsub( /(\d{5})(\d{4})/, "\\1#{@@zip_code_delimiter}\\2" )
      
      self.freeze
    end
    
    def self.street_delimiter
      @@street_delimiter
    end
    
    def state
      @state_or_province
    end
    
    def province
      @state_or_province
    end
    
    def street( delimiter=', ' )
      @streets.join( delimiter )
    end
    
    def self.parse( address )
      raise "Cannot convert #{address.class.to_s.downcase} to an AddressableRecord::Address" unless [Array].include?( address.class )
      self.send( :"parse_#{address.class.to_s.downcase}", address )
    end
    
    def self.convert( address ) #:nodoc:
      parse( address )
    end
    
    def self.parse_street( street ) #:nodoc:
      return street.split( @@street_delimiter )
    end
    
    protected
    
    def raw_street #:nodoc:
      @streets.join( @@street_delimiter )
    end
    
    def raw_zip_code #:nodoc:
      @zip_code.gsub( /#{@@zip_code_delimiter}/, '' )
    end
    
    class << self
      private
    
      def parse_array( address_elements ) #:nodoc:
        state_pos = find_state_position( address_elements )
        raise 'Cannot parse address array.  Failed to find a state.' if state_pos.nil?
        raise 'Cannot parse address array.  No zip code found.' unless address_elements.size >= (state_pos + 1)
        state = States.by_abbreviation.has_key?( address_elements[state_pos] ) ? address_elements[state_pos] : States.by_name[address_elements[state_pos]]
        zip_code = address_elements[state_pos+1].gsub( /#{@@zip_code_delimiter}/, '' )
        country = address_elements.size >= (state_pos + 3) ? address_elements[state_pos+2] : 'United States'
        city = address_elements[state_pos-1]
        streets = []
        (0..state_pos-2).each { |i| streets << address_elements[i] }
        street = streets.join( @@street_delimiter )
        return AddressableRecord::Address.new( :raw_street => street, :city => city, :state_or_province => state, :raw_zip_code => zip_code, :country => country )
      end
      
      def find_state_position( address_elements )
        # Look for state abbreviation
        possible_abbreviation_positions = find_possible_state_abbrev_positions( address_elements )
        state_index = possible_abbreviation_positions.detect { |i| States.by_abbreviation.has_key?( address_elements[i] ) }
        return state_index unless state_index.nil?

        # Look for state name
        (0..address_elements.size-1).detect { |i| States.by_name.has_key?( address_elements[i] ) }
      end
      
      def find_possible_state_abbrev_positions( address_array )
        positions = []
        address_array.each_with_index { |str,i| positions << i if str.size == 2 }
        positions
      end
    end
  end
end