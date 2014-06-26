require 'spec_helper'
require 'rake'
require 'json'
require 'aws'

describe 'opsworks:deploy rake task' do

  before(:all) do
    load File.expand_path("../../lib/opsworks/tasks/opsworks.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  after(:each) do
    Rake::Task["opsworks:deploy"].reenable
  end

  it "should call invoke with argument when given arg" do
    expect(Opsworks::Deploy).to receive(:deploy).with(rails_env: 'test-1', migrate: false)
    Rake::Task["opsworks:deploy"].invoke('test-1')
  end

  it "should call invoke with argument when given env" do
    begin
      ENV['RAILS_ENV'] = "test-2"
      expect(Opsworks::Deploy).to receive(:deploy).with(rails_env: 'test-2', migrate: false)
      Rake::Task["opsworks:deploy"].invoke
    ensure
      ENV['RAILS_ENV'] = nil
    end
  end

  it "should fail when no env supplied deploy" do
    expect { Rake::Task["opsworks:deploy"].invoke() }.to raise_error(ArgumentError)
  end

  it "should run opsworks deploy with migrate" do
    begin
      config = {
        'test-3' => {
          stack_id: 'sid',
          app_id: 'aid'
        }
      }

      # Mock ENV vars
      ENV['RAILS_ENV'] = "test-3"
      ENV['IAM_KEY'] = ENV['IAM_SECRET'] = "a"

      # Allow rails-generated config
      Rails = double("rails")
      expect(Rails).to receive(:root).and_return(".").twice
      expect(File).to receive(:exists?).and_return(true)
      expect(File).to receive(:read).and_return(config.to_json)

      expected_params = { stack_id: "sid", app_id: "aid", command: {name: 'deploy', args: {"migrate" => [ "false" ] } } }

      # Mock the AWS features
      client = double("client")
      expect(client).to receive(:create_deployment).with(expected_params)

      ops_works = double("ops_works")
      expect(ops_works).to receive(:client).and_return(client)


      expect(AWS).to receive(:ops_works).and_return(ops_works)

      # Call rake task
      Rake::Task["opsworks:deploy"].invoke
    ensure # clear ENV vars
      ENV['RAILS_ENV'] = ENV['IAM_KEY'] = ENV['IAM_SECRET'] = nil
    end
  end

  it "should run opsworks deploy without migrate" do
    begin
      config = {
        'test-4' => {
          stack_id: 'sid',
          app_id: 'aid'
        }
      }

      # Mock ENV vars
      ENV['IAM_KEY'] = ENV['IAM_SECRET'] = "a"

      # Allow rails-generated config
      Rails = double("rails")
      expect(Rails).to receive(:root).and_return(".").twice
      expect(File).to receive(:exists?).and_return(true)
      expect(File).to receive(:read).and_return(config.to_json)

      expected_params = { stack_id: "sid", app_id: "aid", command: {name: 'deploy', args: {"migrate" => [ "true" ] } } }

      # Mock the AWS features
      client = double("client")
      expect(client).to receive(:create_deployment).with(expected_params)

      ops_works = double("ops_works")
      expect(ops_works).to receive(:client).and_return(client)


      expect(AWS).to receive(:ops_works).and_return(ops_works)

      # Call rake task
      Rake::Task["opsworks:deploy"].invoke("test-4","true")
    ensure # clear ENV vars
      ENV['RAILS_ENV'] = ENV['IAM_KEY'] = ENV['IAM_SECRET'] = nil
    end
  end

end