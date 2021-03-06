# Opsworks::Deploy

Simple tool to allow to do deploy to AWS Opsworks via a `rake` task.

## Installation

Add this line to your application's Gemfile:

    gem 'opsworks-deploy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install opsworks-deploy

## Usage

To deploy, you will need an set of IAM keys as well as the `stack id` and `app id` from Opsworks.

You can run:

     IAM_KEY=... IAM_SECRET=... STACK_ID=... APP_ID=... rake opsworks:deploy

Or, if you would prefer to add items to config files:

config/stacks.json

    {
      "staging": { "stack_id": "...", "app_id": "...", "custom_json": {} }
    }

~/.aws_config

    aws_access_key_id=...
    aws_secret_access_key=...

Then run:

    ENV=staging AWS_CONFIG_FILE=~/.aws_config rake opsworks:deploy

Note, your IAM keys should only allow deploy access to OpsWorks, but you should never check them into source control.

## Without Rails

To use with other ruby applications, e.g. Sinatra, add the following line to your `Rakefile`:

     require "opsworks/tasks"

This will load the rake task like above.

## Testing

Use rspec for test

    rake test


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Acknowledgements

Thanks to @zacstewart for adding support for custom json.
