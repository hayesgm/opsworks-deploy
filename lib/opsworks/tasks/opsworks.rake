
namespace :opsworks do

  desc 'Deploy to Opsworks'
  task :deploy do |t, args|
    RAILS_ENV ||= ENV['RAILS_ENV']
    raise "Please set RAILS_ENV environment var" if RAILS_ENV.blank?
    
    puts "Deploying #{RAILS_ENV}..."

    Opsworks::Deploy.deploy

    puts "Finished successfully"
  end

end