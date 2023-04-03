require_relative 'lib/richat/version'

Gem::Specification.new do |spec|
  spec.name          = "richat"
  spec.version       = Richat::VERSION
  spec.authors       = ["fzdp"]
  spec.email         = ["fzdp01@gmail.com"]

  spec.summary       = %q{Richat is a command-line ChatGPT tool}
  spec.description   = %q{Richat is a command-line ChatGPT tool implemented in Ruby that supports highly customizable configuration. It can save chat logs, performs fuzzy searches on historical inputs, allows for prompt customization and switching at any time}
  spec.homepage      = "https://github.com/fzdp/richat"
  spec.license       = "MIT"

  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/fzdp/richat"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir["lib/**/*"]
  spec.bindir        = "exe"
  spec.executables   = "richat"

  spec.add_runtime_dependency "faraday", "~> 2.7"

  spec.add_development_dependency "bundler", "~> 2.4.10"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"

  spec.required_ruby_version = ">= 2.6.0"
end
