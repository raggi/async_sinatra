# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{async_sinatra}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Tucker"]
  s.date = %q{2009-03-24}
  s.description = %q{Asynchronous response API for Sinatra}
  s.email = %q{raggi@rubyforge.org}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "Rakefile", "examples/basic.ru", "lib/sinatra/async.rb", "lib/sinatra/async/test.rb", "test/borked_test_crohr.rb", "test/test_async.rb"]
  s.homepage = %q{http://libraggi.rubyforge.org/async_sinatra}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Async Sinatra", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{libraggi}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Asynchronous response API for Sinatra}
  s.test_files = ["test/test_async.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, [">= 0.9.1"])
      s.add_development_dependency(%q<rdoc>, [">= 2.4.1"])
      s.add_development_dependency(%q<rake>, [">= 0.8.3"])
    else
      s.add_dependency(%q<sinatra>, [">= 0.9.1"])
      s.add_dependency(%q<rdoc>, [">= 2.4.1"])
      s.add_dependency(%q<rake>, [">= 0.8.3"])
    end
  else
    s.add_dependency(%q<sinatra>, [">= 0.9.1"])
    s.add_dependency(%q<rdoc>, [">= 2.4.1"])
    s.add_dependency(%q<rake>, [">= 0.8.3"])
  end
end
