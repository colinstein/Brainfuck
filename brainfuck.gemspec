# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'brainfuck/version'

Gem::Specification.new do |spec|
  spec.name          = "brainfuck"
  spec.version       = Brainfuck::VERSION
  spec.date          = "2017-03-29"
  spec.authors       = ["Colin Stein"]
  spec.email         = ["colinstein@mac.com"]
  spec.homepage      = "https://github.com/colinstein/brainfuck"
  spec.license       = "MIT"

  spec.summary       = "An interpreter for the BrainFuck programing language"
  spec.description   = <<~DESCRIPTION
                       This is an Interpreter for the BrianFuck programming
                       language. It has a terse sytnax and few features but it
                       is Turing-complete. You can read its description at
                       http://www.muppetlabs.com/~breadbox/bf/.
                       DESCRIPTION

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://gems.colins.me/"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "codecov", "~> 0.1.10"
end
