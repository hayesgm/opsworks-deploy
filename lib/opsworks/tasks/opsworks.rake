
namespace :opsworks do

  desc 'Deploy to Opsworks'
  task :deploy, [:rails_env] => :environment do |t, args|
    rails_env = args[:rails_env] || ENV['RAILS_ENV']
    
    raise ArgumentError, "Please pass rails_env as argument or set RAILS_ENV environment var" if rails_env.nil? || rails_env == ""
    
    puts "Deploying #{rails_env}..."

    Opsworks::Deploy.deploy(rails_env: rails_env)

    puts "Finished successfully"
  end

end