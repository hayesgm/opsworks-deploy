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

  # Look for config/stacks.json or stacks.json
  def self.get_config_stacks
    cwd = Dir.getwd
    files = ["#{cwd}/config/stacks.json","#{cwd}/stacks.json"]

    if !cwd.nil? && cwd.length > 0
      files.each do |file|
        if File.exists?(file)
          return JSON(File.read(file))
        end
      end
    end

    return nil
  end

  def self.get_stack(env=nil)

    # First try to get from env, then stack files
    if !ENV['STACK_ID'].nil? && !ENV['APP_ID'].nil?
      return {stack_id: ENV['STACK_ID'], app_id: ENV['APP_ID']}
    elsif stacks = get_config_stacks
      raise "Missing stacks configuration for #{env} in stacks.json" if stacks[env].nil?

      return stacks[env]
    else
      raise "Must set STACK_ID and APP_ID or have config/stacks.json for env `#{env}`"
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
    opts = {
      migrate: true,
      wait: false,
      env: nil
    }.merge(opts)

    stack = Opsworks::Deploy.get_stack(opts[:env]) # Get stack environment

    Opsworks::Deploy.configure_aws! # Ensure we are properly configured
    
    deployment = AWS.ops_works.client.create_deployment( stack_id: stack[:stack_id] || stack['stack_id'], app_id: stack[:app_id] || stack['app_id'], command: {name: 'deploy', args: {"migrate" => [ opts[:migrate] ? "true" : "false"] }} )

    puts deployment.inspect

    Opsworks::Deploy.wait_on_deployment(deployment) if opts[:wait]
  end

end
