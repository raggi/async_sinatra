# -*- encoding: utf-8 -*-
# stub: async_sinatra 1.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "async_sinatra".freeze
  s.version = "1.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["raggi".freeze]
  s.date = "2017-05-23"
  s.description = "A Sinatra plugin to provide convenience whilst performing asynchronous\nresponses inside of the Sinatra framework running under async webservers.\n\nTo properly utilise this package, some knowledge of EventMachine and/or\nasynchronous patterns is recommended.\n\nCurrently, supporting servers include:\n\n* Thin\n* Rainbows\n* Zbatery".freeze
  s.email = ["jftucker@gmail.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "CHANGELOG.rdoc".freeze, "README.rdoc".freeze]
  s.files = [".gemtest".freeze, "CHANGELOG.rdoc".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "examples/basic.ru".freeze, "lib/async_sinatra.rb".freeze, "lib/sinatra/async.rb".freeze, "lib/sinatra/async/test.rb".freeze, "test/test_async.rb".freeze]
  s.homepage = "http://github.com/raggi/async_sinatra".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "2.6.11".freeze
  s.summary = "A Sinatra plugin to provide convenience whilst performing asynchronous responses inside of the Sinatra framework running under async webservers".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>.freeze, [">= 2.0.0"])
      s.add_runtime_dependency(%q<sinatra>.freeze, [">= 1.4.8"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.10"])
      s.add_development_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_development_dependency(%q<hoe-doofus>.freeze, [">= 1.0"])
      s.add_development_dependency(%q<hoe-seattlerb>.freeze, [">= 1.2"])
      s.add_development_dependency(%q<hoe-git>.freeze, [">= 1.3"])
      s.add_development_dependency(%q<hoe-gemspec2>.freeze, [">= 1.0"])
      s.add_development_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_development_dependency(%q<eventmachine>.freeze, [">= 0.12.11"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.16"])
    else
      s.add_dependency(%q<rack>.freeze, [">= 2.0.0"])
      s.add_dependency(%q<sinatra>.freeze, [">= 1.4.8"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.10"])
      s.add_dependency(%q<rack-test>.freeze, [">= 0"])
      s.add_dependency(%q<hoe-doofus>.freeze, [">= 1.0"])
      s.add_dependency(%q<hoe-seattlerb>.freeze, [">= 1.2"])
      s.add_dependency(%q<hoe-git>.freeze, [">= 1.3"])
      s.add_dependency(%q<hoe-gemspec2>.freeze, [">= 1.0"])
      s.add_dependency(%q<rdoc>.freeze, [">= 0"])
      s.add_dependency(%q<eventmachine>.freeze, [">= 0.12.11"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
    end
  else
    s.add_dependency(%q<rack>.freeze, [">= 2.0.0"])
    s.add_dependency(%q<sinatra>.freeze, [">= 1.4.8"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.10"])
    s.add_dependency(%q<rack-test>.freeze, [">= 0"])
    s.add_dependency(%q<hoe-doofus>.freeze, [">= 1.0"])
    s.add_dependency(%q<hoe-seattlerb>.freeze, [">= 1.2"])
    s.add_dependency(%q<hoe-git>.freeze, [">= 1.3"])
    s.add_dependency(%q<hoe-gemspec2>.freeze, [">= 1.0"])
    s.add_dependency(%q<rdoc>.freeze, [">= 0"])
    s.add_dependency(%q<eventmachine>.freeze, [">= 0.12.11"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.16"])
  end
end
