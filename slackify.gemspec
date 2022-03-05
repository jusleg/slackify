# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'slackify'
  s.version     = '0.4.1'
  s.date        = '2019-12-11'
  s.summary     = 'Slackbot framework for Rails using the Events API'
  s.description = 'Slackbot framework for Rails using the Events API. Supports events, interactive messages and slash commands.'
  s.authors     = ['Justin Leger', 'Michel Chatmajian']
  s.email       = 'hey@justinleger.ca'
  s.files = Dir["{app,config,lib}/**/*", "Rakefile", "README.md", "CHANGELOG.md"]
  s.homepage    = 'https://github.com/jusleg/slackify'
  s.license     = 'MIT'

  s.metadata = {
    "source_code_uri" => "https://github.com/jusleg/slackify",
    "changelog_uri" => "https://github.com/jusleg/slackify/blob/master/CHANGELOG.md"
  }

  s.add_dependency 'rails'
  s.add_dependency 'slack-ruby-client', '>= 0.15.1'
  s.add_dependency 'strscan'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
end
