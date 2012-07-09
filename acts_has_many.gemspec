require File.expand_path('../lib/acts_has_many/version', __FILE__)

Gem::Specification.new do |gem|

  gem.name = 'acts_has_many'
  gem.summary = 'makes has_many clearer'
  gem.files = ['lib/acts_has_many.rb']
  gem.author = 'Igor IS04'
  gem.homepage = "https://github.com/igor04/acts_has_many"

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.version       = ActsHasMany::VERSION
  
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'activerecord'
end

