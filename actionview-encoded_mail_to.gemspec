# -*- encoding: utf-8 -*-
require File.expand_path('../lib/action_view/encoded_mail_to/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'actionview-encoded_mail_to'
  s.version       = ActionView::EncodedMailTo::VERSION
  s.authors       = 'Nick Reed'
  s.email         = 'reednj77@gmail.com'
  s.description   = %q{Rails mail_to helper with encoding (removed from core in Rails 4.0)}
  s.summary       = %q{Deprecated support for email address obfuscation within the mail_to helper method.}
  s.homepage      = 'https://github.com/reednj77/actionview-encoded_mail_to'

  s.add_dependency 'rails'
  s.add_development_dependency 'minitest'
  
  s.files         = Dir["#{File.dirname(__FILE__)}/**/*"]
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
end
