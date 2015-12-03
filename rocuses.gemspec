# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rocuses'

Gem::Specification.new do |spec|
  spec.name          = "rocuses"
  spec.version       = Rocuses::VERSION
  spec.authors       = ["Toshifumi Sakaguchi"]
  spec.email         = ["siskrn@gmail.com"]
  spec.description   = %q{performance monitoring tools}
  spec.summary       = %q{performance monitoring tools}
  spec.homepage      = ""
  spec.license       = "BSD"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "log4r"
  spec.add_development_dependency "net-ldap"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "flexmock"
end
