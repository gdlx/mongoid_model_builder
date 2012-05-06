# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mongoid_model_builder/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Gauthier Delacroix"]
  gem.email         = ["gauthier.delacroix@gmail.com"]
  gem.description   = "%q{mongoid_model_builder dynamically creates Mongoid model classes following configuration hash specifications}"
  gem.summary       = "%q{Dynamic Mongoid model classes generator}"
  gem.homepage      = "https://github.com/porecreat/mongoid_model_builder"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mongoid_model_builder"
  gem.require_paths = ["lib"]
  gem.version       = Mongoid::ModelBuilder::VERSION
  
  gem.add_runtime_dependency('hashery', '1.5.0')
  gem.add_runtime_dependency('mongoid', '~> 2.4')
end
