# CloudFactory Gem

A ruby library to interact with the [CloudFactory](http://cloudfactory.com) RESTFul API.

Currently tested with:
* ruby-1.9.2-p180

## Installing the gem via source

```ruby
gem install cloud_factory
```

But until we publish the gem you need to clone, build and install it manually

```bash
git clone git@github.com:sprout/cloudfactory_ruby.git
cd cloudfactory_ruby
git checkout origin/develop
gem build cloud_factory.gemspec
gem install cloud_factory-0.0.1.gem
```

## Getting Started

After installing the gem, you will get a `cf` cmd tool.

Now you've to setup the `target uri`. Its necessary while creating a line and starting a production run.

```bash
  cf target --url=http://staging.cloudfactory.com
```

## Generate a line
```bash
  cf line generate first-line
```

Change the `api_key` in the generated `first-line/line.yml` file.
Then run `cf production start --title=first-line-run --input-data=first-line-run.csv`
This should create a line and do production run.

```bash
± cf                                                                                                                                                                                                
Tasks:
  cf form             # Commands to generate custom task forms. For more info, cf form help
  cf help [TASK]      # Describe available tasks or one specific task
  cf line             # Commands to manage the Lines. For more info, cf line help
  cf login --url=URL  # Setup the cloudfactory credentials
  cf production       # Commands to create production runs. For more info, cf production help


± cf line help                                                                                                                                                                                      
Tasks:
  cf help [COMMAND]            # Describe subcommands or one specific subcommand
  cf line create               # takes the yaml file at line.yml and creates a new line at http://cloudfactory.com
  cf line generate LINE-TITLE  # genarates a line template at <line-title>/line.yml
```

## Development
```ruby
RESTCLIENT_LOG=stdout TEST=1 be rspec spec/line_spec.rb -d