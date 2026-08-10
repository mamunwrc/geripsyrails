require_relative 'controller_macros'
RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.extend ControllerMacros, :type => :controller
  config.include ControllerMacros, :type => :controller
end

