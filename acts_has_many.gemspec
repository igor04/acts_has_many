# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'acts_has_many/version'

Gem::Specification.new do |gem|

  gem.name     = 'acts_has_many'
  gem.version  = ActsHasMany::VERSION
  gem.summary  = 'All records must be used, otherwise they will be deleted. Clear logic with has_many'
  gem.description = 'This gem gives functional for update elements has_many relation'
  gem.author   = 'Igor IS04'
  gem.email    = 'igor.s04g@gmail.com'
  gem.homepage = 'https://github.com/igor04/acts_has_many'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.5'
  gem.add_development_dependency 'rake', '~> 10'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'sqlite3', '~> 1.3'
  gem.add_development_dependency 'activerecord', '~> 3.2'
end

