module AddressableRecord
  module ActiveRecordExtensions
    def self.included( base )
      base.extend ActsMethods
    end

    module ActsMethods
      def address( *args )
        unless included_modules.include? InstanceMethods
          self.class_eval { extend ClassMethods }
          include InstanceMethods
        end
        initialize_compositions( args )
      end

      alias_method :addresses, :address
    end

    module ClassMethods
      def initialize_compositions( attrs )
        attrs.each do |attr|
          composed_of attr, :class_name => 'AddressableRecord::Address', :converter => :convert, :allow_nil => true, 
            :mapping => [["#{attr}_raw_street", 'raw_street'], ["#{attr}_city", 'city'], ["#{attr}_state_or_province", 'state_or_province'], ["#{attr}_raw_zip_code", 'raw_zip_code'], ["#{attr}_country", 'country']],
            :constructor => Proc.new { |raw_street, city, state_or_province, raw_zip_code, country| AddressableRecord::Address( :raw_street => raw_street, :city => city, :state_or_province => state_or_province, :raw_zip_code => raw_zip_code, :country => country ) }
        end
      end
    end

    module InstanceMethods

    end
  end
end