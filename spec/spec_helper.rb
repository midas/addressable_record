$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'active_record'
require 'addressable_record'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  
end

require File.dirname(__FILE__) + '/../script/environment'
