
namespace :opsworks do

  desc 'Deploy to Opsworks'
  task :deploy, [:env,:migrate] => [] do |t, args|
    env = args[:env] || ENV['ENV'] || ENV['RAILS_ENV']
    migrate = args[:migrate] == "true" || args[:migrate] == "t"

    raise ArgumentError, "Please pass env as argument or set ENV or RAILS_ENV environment var" if env.nil? || env == ""
    
    puts "Deploying #{env}#{migrate ? " and running migrations" : ""}..."

    Opsworks::Deploy.deploy(env: env, migrate: migrate)

    puts "Finished successfully"
  end

end