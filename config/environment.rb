# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Bacchus::Application.initialize!

Time::DATE_FORMATS[:simple] = "%d/%m/%Y"