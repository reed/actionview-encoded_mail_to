source 'https://rubygems.org'

gemspec

gem 'railties', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']
gem 'mime-types', '~> 2' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0')
gem 'rack', '~> 1' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2')
