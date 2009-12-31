class AddressableRecordMigrationGenerator < Rails::Generator::NamedBase
  def initialize( runtime_args, runtime_options={} )
    super
    @stamp = DateTime.now.utc.strftime( "%Y%m%d%H%M%S" )
    parse_args( args )
  end

  def manifest
    record do |m|
      m.directory "db/migrate"
      m.template  "migration.rb", "db/migrate/#{@stamp}_#{name}.rb", :assigns => { :table => @table, :field => @field }
    end
  end

  private

  def parse_args( args )
    @table = args[0]
    @field = args[1]
  end
end