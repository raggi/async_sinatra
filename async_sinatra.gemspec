# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{async_sinatra}
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["raggi"]
  s.cert_chain = ["/Users/raggi/.gem/gem-public_cert.pem"]
  s.date = %q{2011-03-08}
  s.description = %q{A Sinatra plugin to provide convenience whilst performing asynchronous
responses inside of the Sinatra framework running under async webservers.

To properly utilise this package, some knowledge of EventMachine and/or
asynchronous patterns is recommended.

Currently, supporting servers include:

* Thin
* Rainbows
* Zbatery}
  s.email = ["raggi@rubyforge.org"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = [".gemtest", "CHANGELOG.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "examples/basic.ru", "lib/async_sinatra.rb", "lib/sinatra/async.rb", "lib/sinatra/async/test.rb", "test/gemloader.rb", "test/test_async.rb"]
  s.homepage = %q{http://github.com/raggi/async_sinatra}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{libraggi}
  s.rubygems_version = %q{1.6.0}
  s.signing_key = %q{/Users/raggi/.gem/gem-private_key.pem}
  s.summary = %q{A Sinatra plugin to provide convenience whilst performing asynchronous responses inside of the Sinatra framework running under async webservers}
  s.test_files = ["test/test_async.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.2.1"])
      s.add_runtime_dependency(%q<sinatra>, [">= 1.0"])
      s.add_development_dependency(%q<minitest>, [">= 2.0.2"])
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_development_dependency(%q<hoe-doofus>, [">= 1.0"])
      s.add_development_dependency(%q<hoe-seattlerb>, [">= 1.2"])
      s.add_development_dependency(%q<hoe-git>, [">= 1.3"])
      s.add_development_dependency(%q<hoe-gemspec2>, [">= 1.0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<eventmachine>, [">= 0.12.11"])
      s.add_development_dependency(%q<hoe>, [">= 2.9.1"])
    else
      s.add_dependency(%q<rack>, [">= 1.2.1"])
      s.add_dependency(%q<sinatra>, [">= 1.0"])
      s.add_dependency(%q<minitest>, [">= 2.0.2"])
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
      s.add_dependency(%q<hoe-doofus>, [">= 1.0"])
      s.add_dependency(%q<hoe-seattlerb>, [">= 1.2"])
      s.add_dependency(%q<hoe-git>, [">= 1.3"])
      s.add_dependency(%q<hoe-gemspec2>, [">= 1.0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<eventmachine>, [">= 0.12.11"])
      s.add_dependency(%q<hoe>, [">= 2.9.1"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.2.1"])
    s.add_dependency(%q<sinatra>, [">= 1.0"])
    s.add_dependency(%q<minitest>, [">= 2.0.2"])
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    s.add_dependency(%q<hoe-doofus>, [">= 1.0"])
    s.add_dependency(%q<hoe-seattlerb>, [">= 1.2"])
    s.add_dependency(%q<hoe-git>, [">= 1.3"])
    s.add_dependency(%q<hoe-gemspec2>, [">= 1.0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<eventmachine>, [">= 0.12.11"])
    s.add_dependency(%q<hoe>, [">= 2.9.1"])
  end
end
