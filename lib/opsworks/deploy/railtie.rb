
module Opsworks::Deploy
  class Railtie < Rails::Railtie
    railtie_name :opsworks_deploy

    rake_tasks do
      load "opsworks/tasks/opsworks.rake"
    end
  end
end