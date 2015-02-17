require "opsworks/deploy/version"
require 'aws-sdk'

module Opsworks::Deploy
  DEPLOYMENT_POLL_INTERVAL = 10

  require 'opsworks/deploy/railtie' if defined?(Rails)

  def self.configure_aws!
    # First, try to pull these from the environment
    iam_key = ENV['IAM_KEY']
    iam_secret = ENV['IAM_SECRET']

    # Otherwise, we'll pull them from config
    if ( iam_key.nil? || iam_secret.nil? ) && ENV['AWS_CONFIG_FILE']
      config = File.read(ENV['AWS_CONFIG_FILE'])
      iam_key = $1 if config =~ /^aws_access_key_id=(.*)$/
      iam_secret = $1 if config =~ /^aws_secret_access_key=(.*)$/
    end

    raise ArgumentError, "Must set IAM_KEY environment variable" if iam_key.nil? || iam_key.length == 0
    raise ArgumentError, "Must set IAM_SECRET environment variable" if iam_secret.nil? || iam_secret.length == 0

    AWS.config({
      access_key_id: iam_key,
      secret_access_key: iam_secret,
    })
  end

  def self.deploy(opts={})
    Deployment.new(opts).deploy
  end

  class Deployment
    attr_reader :client, :deployment, :options

    def initialize(options, client = AWS.ops_works.client)
      @options = {
        migrate: true,
        wait: false,
        env: nil
      }.merge(options)
      @client = client

      Opsworks::Deploy.configure_aws!
    end

    def deploy
      @deployment = client.create_deployment(arguments)
      puts @deployment.inspect
      wait_on_deployment if options[:wait]
    end

    private

    def arguments
      {
        stack_id: configuration['stack_id'],
        app_id: configuration['app_id'],
        command: command
      }.tap do |args|
        args[:custom_json] = custom_json if custom_json?
      end
    end

    def command
      {name: 'deploy', args: {'migrate' => [options[:migrate] ? 'true' : 'false']}}
    end

    def custom_json
      configuration['custom_json'].to_json
    end

    def custom_json?
      configuration.has_key?('custom_json')
    end

    def configuration
      @configuration ||= if !ENV['STACK_ID'].nil? && !ENV['APP_ID'].nil?
        {'stack_id' => ENV['STACK_ID'], 'app_id' => ENV['APP_ID']}
      elsif stacks = configured_environments
        stacks.fetch(environment) do
          raise "Missing stacks configuration for #{environment} in stacks.json"
        end
      else
        raise "Must set STACK_ID and APP_ID or have config/stacks.json for env `#{environment}`"
      end
    end

    def environment
      options.fetch(:env)
    end

    # Look for config/stacks.json or stacks.json
    def configured_environments
      files = Dir['config/stacks.json','stacks.json']
      file = files.first and JSON.parse(File.read(file))
    end

    def wait_on_deployment
      deployment_id = deployment.data[:deployment_id]
      loop do
        deployment_description = client.describe_deployments(
            deployment_ids: [deployment_id]
        )
        status = deployment_description.data[:deployments].first[:status]

        case status
        when 'running' then sleep DEPLOYMENT_POLL_INTERVAL
        when 'successful' then break
        else
          raise "Failed to run deployment: #{deployment_id} - #{status}"
        end
      end
    end
  end

end
