# Loads opsworks-deploy tasks from non-Rails application

# See: http://pivotallabs.com/how-i-test-rake-tasks/
# See: http://stackoverflow.com/questions/15446153/ruby-rake-load-tasks-from-a-gem
# See: http://stackoverflow.com/questions/5458134/how-do-i-import-rake-tasks-from-a-gem-when-using-sinatra
require File.join(File.dirname(__FILE__), '../opsworks-deploy')

spec = Gem::Specification.find_by_name 'opsworks-deploy'
load "#{spec.gem_dir}/lib/opsworks/tasks/opsworks.rake"
