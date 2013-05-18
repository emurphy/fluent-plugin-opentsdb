# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-opentsdb"
  gem.version       = "0.1.1"
  gem.authors       = ["Emmet Murphy"]
  gem.email         = ["emmet@onekingslane.com"]
  gem.description   = %q{Fluentd plugin to graph fluent-plugin-numeric-monitor values in OpenTSDB}
  gem.summary       = %q{Fluentd plugin to graph fluent-plugin-numeric-monitor values in OpenTSDB}
  gem.homepage      = "https://github.com/emurphy/fluent-plugin-opentsdb"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "fluentd"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rspec-mocks"


  gem.add_runtime_dependency "fluentd"
end
