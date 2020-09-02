# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'slackify'
  s.version     = '0.3.2'
  s.date        = '2019-12-11'
  s.summary     = 'Slackbot framework for Rails using the Events API'
  s.description = 'Slackbot framework for Rails using the Events API. Supports events, '\
    'interactive messages and slash commands.'
  s.authors     = ['Justin Leger', 'Michel Chatmajian']
  s.email       = 'hey@justinleger.ca'
  s.files = Dir["{app,config,lib}/**/*", "Rakefile", "README.md", "CHANGELOG.md"]
  s.homepage    = 'https://github.com/Shopify/slackify'
  s.license     = 'MIT'

  s.metadata = {
    "source_code_uri" => "https://github.com/Shopify/slackify",
    "changelog_uri" => "https://github.com/Shopify/slackify/blob/master/CHANGELOG.md",
  }

  s.add_dependency('rails')
  s.add_dependency('slack-ruby-client')
  s.add_dependency('strscan')
  s.add_development_dependency('byebug')
  s.add_development_dependency('minitest')
  s.add_development_dependency('mocha')
  s.add_development_dependency('rake')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('rubocop-shopify')
end
