# frozen_string_literal: true

require_relative 'lib/laneful/version'

Gem::Specification.new do |spec|
  spec.name          = 'laneful-ruby'
  spec.version       = Laneful::VERSION
  spec.authors       = ['Laneful Team']
  spec.email         = ['support@laneful.com']

  spec.summary       = 'Ruby SDK for the Laneful email API'
  spec.description   = 'A modern Ruby client library for the Laneful email API, ' \
                       'providing easy integration for email sending, webhooks, and analytics.'
  spec.homepage      = 'https://github.com/laneful/laneful-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/laneful/laneful-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/laneful/laneful-ruby/blob/main/CHANGELOG.md'
  spec.metadata['documentation_uri'] = 'https://docs.laneful.com/ruby'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'httparty', '~> 0.21'
  spec.add_dependency 'json', '~> 2.6'
end
