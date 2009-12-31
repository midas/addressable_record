class <%= class_name %> < ActiveRecord::Migration
  def self.up
    add_column :<%= table %>, :<%= field %>_street, :string, :limit => 255
    add_column :<%= table %>, :<%= field %>_city, :string, :limit => 50
    add_column :<%= table %>, :<%= field %>_state_or_province, :string, :limit => 50
    add_column :<%= table %>, :<%= field %>_zip_code, :string, :limit => 9
    add_column :<%= table %>, :<%= field %>_country, :string, :limit => 75
  end

  def self.down
    remove_column :<%= table %>, :<%= field %>_street
    remove_column :<%= table %>, :<%= field %>_city
    remove_column :<%= table %>, :<%= field %>_state_or_province
    remove_column :<%= table %>, :<%= field %>_zip_code
    remove_column :<%= table %>, :<%= field %>_country
  end
end