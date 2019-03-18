# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'toddlerbot'
  s.version     = '0.1.0'
  s.date        = '2019-03-17'
  s.summary     = 'Rails slackbot framework'
  s.description = 'Slackbot framework for Rails using the Events API'
  s.authors     = ['Justin Leger', 'Michel Chatmajian']
  s.email       = 'hey@justinleger.ca'
  s.files = Dir["{app,config,lib}/**/*", "Rakefile", "README.md", "CHANGELOG.md"]
  s.homepage    = 'https://github.com/jusleg/toddlerbot'
  s.license     = 'MIT'

  s.metadata = {
    "source_code_uri" => "https://github.com/jusleg/toddlerbot",
    "changelog_uri" => "https://github.com/jusleg/toddlerbot/blob/master/CHANGELOG.md"
  }

  s.add_dependency 'rails'
  s.add_dependency 'slack-ruby-client'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
end
