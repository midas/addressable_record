require File.dirname(__FILE__) + '/states'

module AddressableRecord
  class Address
    NATURAL_OR_CSV_STRING_REGEX = /^\s*?(?:([^,]+?)),\s*?(?:([^,]+?)),\s*?(?:(?:([^,]+?)),\s*?)??([A-Z]{2}),??\s*?(\d{5}(?:-\d{4})?)\s*$/ # /^(.+),\s*(.+),\s*(.+),\s*(.{2}),?\s*(\d{5})-?(\d{4})?\s*$/
    NATURAL_OR_CSV_STRING_INVALID_MESSAGE = "invalid format, try something like: 123 Some Street, Suite 123, Some City, AL 11111-1111"
    NATURAL_STRING_REGEX = /^(.+),\s*(.+),\s*(.+),\s*(.{2})\s*(\d{5})-?(\d{4})?\s*$/
    CSV_STRING_REGEX = /^(.+),\s*(.+),\s*(.+),\s*(.{2}),\s*(\d{5})-?(\d{4})?\s*$/

    attr_reader :raw_street, :streets, :city, :state_or_province, :zip_code, :zip_code_prefix, :zip_code_ext, :country

    @@street_delimiter ||= '###'
    @@zip_code_delimiter ||= '-'
    @@patterns ||= {
            :us_long => "%s, %c, %S %z %C",
            :us => "%s, %c, %S %z"
    }

    def initialize( attrs )
      raise 'Initilaizer argument must be an attributes hash.' unless attrs.is_a?( Hash )
      @city, @state_or_province, @country = attrs[:city], attrs[:state_or_province], attrs[:country]

      @streets = AddressableRecord::Address.parse_street( attrs[:raw_street] || '' )
      raw_zip = (attrs[:raw_zip_code] || '')
      @zip_code = raw_zip.size == 5 ? raw_zip : raw_zip.gsub( /(\d{5})(\d{4})/, "\\1#{@@zip_code_delimiter}\\2" )
      @zip_code_prefix = raw_zip.gsub( /(\d{5})(\d{4}?)/, "\\1" )
      @zip_code_ext = raw_zip.gsub( /(\d{5})(\d{4}?)/, "\\2" )

      @pattern_map = {
              '%s' => @streets.join( ', ' ) || "",
              '%1' => @streets[0] || "",
              '%2' => @streets[1] || "",
              '%3' => @streets[2] || "",
              '%4' => @streets[3] || "",
              '%5' => @streets[4] || "",
              '%c' => @city || "",
              '%S' => @state_or_province || "",
              '%z' => @zip_code || "",
              '%C' => @country || ""
      }

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
      return @streets.nil? ? '' : @streets.join( delimiter )
    end

    def self.parse( address )
      unless [Array, Hash, String].include?( address.class )
        raise "Cannot convert #{address.class.to_s.downcase} to an AddressableRecord::Address"
      end
      self.send( :"parse_#{address.class.to_s.downcase}", address )
    end

    def self.convert( address ) #:nodoc:
      parse( address )
    end

    def self.parse_street( street ) #:nodoc:
      return street.split( @@street_delimiter )
    end

    # Outputs a address based on pattern provided.
    #
    # Symbols:
    #   %s - street
    #   %c - city
    #   %S - state
    #   %z - zip code
    #   %C - country
    #
    def to_s( pattern=nil )
      return '' if is_blank?
      to_return = pattern.is_a?( Symbol ) ? @@patterns[pattern] : pattern
      to_return = @@patterns[:us] if to_return.nil? || to_return.empty?
      @pattern_map.each { |pat, replacement| to_return = to_return.gsub( pat, replacement ) }
      to_return.strip
    end

    def is_blank?
      raw_street.blank? && city.blank? && state_or_province.blank? && raw_zip_code.blank? && country.blank?
    end

    def ==( other )
      return false unless other.instance_of?( self.class )
      return false unless other.raw_street.upcase == raw_street.upcase
      return false unless other.city.upcase == city.upcase
      return false unless other.state_or_province.upcase  == state_or_province.upcase
      return false unless other.raw_zip_code == raw_zip_code
      return false unless other.country.upcase == country.upcase

      true
    end

    # Outputs the parts of teh address delimited by specified delimiter(s).
    #
    # *parameters*
    # opts:: Can be a string that is the delimiter or an an options hash.
    #
    # *options*
    # delimiter:: The string to delimit the address with.
    # street_delimiter:: An additional delimiter to use only on the street fields.
    # country:: Outputs the country when true, otherwise no country is output (defaults to false).
    #
    def join( opts )
      if opts.is_a?( Hash )
        options = opts
        options[:street_delimiter] ||= options[:delimiter]
      elsif opts.is_a?( String )
        options = {}
        options[:street_delimiter] = options[:delimiter] = opts
        options[:country] = false
      end

      to_return = "#{self.street( options[:street_delimiter] )}#{options[:delimiter]}#{self.city}, #{self.state_or_province} #{self.zip_code}"
      return options[:country] ? to_return + "#{options[:delimiter]}#{self.country}" : to_return
    end

    def raw_street #:nodoc:
      return @streets.nil? ? '' : @streets.join( @@street_delimiter ) #@streets.join( @@street_delimiter )
    end

    def raw_zip_code #:nodoc:
      return @zip_code.nil? ? '' : @zip_code.gsub( /#{@@zip_code_delimiter}/, '' )
    end

    class << self
      private

      def parse_array( address_elements ) #:nodoc:
        state_pos = find_state_position( address_elements )
        # puts address_elements.class.name, address_elements, state_pos
        # raise 'Cannot parse address array.  Failed to find a state.' if state_pos.nil?
        # raise 'Cannot parse address array.  No zip code found.' unless address_elements.size >= (state_pos + 1)
        return nil if state_pos.nil?
        return nil unless address_elements.size >= (state_pos + 1)
        state = States.by_abbreviation.has_key?( address_elements[state_pos] ) ? address_elements[state_pos] : States.by_name[address_elements[state_pos]]
        zip_code = address_elements[state_pos+1].gsub( /#{@@zip_code_delimiter}/, '' )
        country = address_elements.size >= (state_pos + 3) ? address_elements[state_pos+2] : 'U.S.A.'
        city = address_elements[state_pos-1]
        streets = []
        (0..state_pos-2).each { |i| streets << address_elements[i].strip }
        street = streets.join( @@street_delimiter )
        return AddressableRecord::Address.new( :raw_street => street, :city => city, :state_or_province => state, :raw_zip_code => zip_code, :country => country )
      end

      def parse_hash( address )
        return AddressableRecord::Address.new( address )
      end

      def parse_string( address )
        parts = nil
        pos = find_state_position_in_string( address )
        return blank_address if pos.nil?

        if !pos.nil? && address[pos+2,1] == ','
          parts = address.split( ',' )
          parts = parts.map { |p| p.strip }
        else
          pre_state_string = address[0,pos]
          parts = pre_state_string.split( ',' ).reject { |p| p.blank? }
          state_on_string = address[pos,address.size-pos]
          parts += state_on_string.split( /\s+/ ).reject { |p| p.blank? }
        end

        parse_array( parts )
      end

      def blank_address
        self.new( {} )
      end

      def find_state_position( address_elements )
        unless [Array,String].include?( address_elements.class )
          raise "Cannot search for state position in a #{address_elements.class.name}"
        end
        self.send( :"find_state_position_in_#{address_elements.class.to_s.downcase}", address_elements )
      end

      def find_state_position_in_array( address_elements )
        # Look for state abbreviation
        possible_abbreviation_positions = find_possible_state_abbrev_positions( address_elements )
        state_index = possible_abbreviation_positions.detect { |i| States.by_abbreviation.has_key?( address_elements[i] ) }
        return state_index unless state_index.nil?

        # Look for state name
        (0..address_elements.size-1).detect { |i| States.by_name.has_key?( address_elements[i] ) }
      end

      def find_state_position_in_string( address_elements )
        idx = nil
        States.abbreviations.each do |abbreviation|
          idx = address_elements.rindex( abbreviation )
          return idx unless idx.nil?
        end

        States.names.each do |name|
          idx = address_elements.rindex( name )
          return idx unless idx.nil?
        end

        nil
      end

      def find_possible_state_abbrev_positions( address_array )
        positions = []
        address_array.each_with_index { |str, i| positions << i if str.size == 2 }
        positions
      end
    end
  end
end
