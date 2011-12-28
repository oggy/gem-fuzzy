$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'gem_info'

RSpec.configure do |config|
  config.mock_with :mocha
end

# So we don't have to qualify all our classes.
include GemInfo
