require "opsworks/deploy/version"
require 'aws-sdk'

module Opsworks::Deploy

  require 'opsworks/deploy/railtie' if defined?(Rails)

  def self.wait_on_deployment(deployment)
    deployment_id = deployment.data[:deployment_id]
    while true
      deployment_desc = AWS.ops_works.client.describe_deployments(deployment_ids: [deployment_id])

      status = deployment_desc.data[:deployments].first[:status]

      case status
      when 'running'
        sleep 10
      when 'successful'
        return true
      else
        raise "Failed to run deployment: #{deployment_id} - #{status}"
      end
    end
  end


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
    attr_reader :options

    def initialize(options)
      @options = {
        migrate: true,
        wait: false,
        env: nil
      }.merge(options)

      Opsworks::Deploy.configure_aws! # Ensure we are properly configured
    end

    def deploy
      deployment = AWS.ops_works.client.create_deployment(arguments)

      puts deployment.inspect

      Opsworks::Deploy.wait_on_deployment(deployment) if options[:wait]
    end

    private

    def arguments
      {
        stack_id: configuration['stack_id'],
        app_id: configuration['app_id'],
        command: command
      }
    end

    def command
      {name: 'deploy', args: {'migrate' => [options[:migrate] ? 'true' : 'false']}}
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
  end

end
