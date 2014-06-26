
namespace :opsworks do

  desc 'Deploy to Opsworks'
  task :deploy, [:rails_env,:migrate] => :environment do |t, args|
    rails_env = args[:rails_env] || ENV['RAILS_ENV']
    migrate = args[:migrate] == "true" || args[:migrate] == "t"

    raise ArgumentError, "Please pass rails_env as argument or set RAILS_ENV environment var" if rails_env.nil? || rails_env == ""
    
    puts "Deploying #{rails_env}#{migrate ? " and running migrations" : ""}..."

    Opsworks::Deploy.deploy(rails_env: rails_env, migrate: migrate)

    puts "Finished successfully"
  end

end