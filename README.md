# CloudFactory Gem

A ruby library to interact with the [CloudFactory](http://cloudfactory.com) RESTFul API.

Currently tested with:
* ruby-1.9.2-p180

## Getting Started

```ruby
gem install cloudfactory
```

But until we publish the gem you need to clone, build and install it manually
```ruby
git clone git@github.com:sprout/cloudfactory_ruby.git
cd cloudfactory_ruby
gem build cloud_factory.gemspec
gem install cloud_factory-0.0.1.gem
```

## Development
```ruby
RESTCLIENT_LOG=stdout TEST=1 be rspec spec/line_spec.rb -d
```