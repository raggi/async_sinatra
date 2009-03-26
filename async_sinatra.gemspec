Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = 'async_sinatra'
  s.version = '0.1.0'
  s.date = '2009-03-24'

  s.description = "Asynchronous response API for Sinatra and Thin"
  s.summary     = s.description

  s.authors = ["James Tucker"]
  s.email = "raggi@rubyforge.org"

  s.files = %w[]

  s.test_files = s.files.select {|path| path =~ /^spec\/spec_.*\.rb/}

  s.extra_rdoc_files = %w[README.rdoc]
  
  s.add_dependency 'sinatra',    '>= 0.9.1'
  s.add_dependency 'thin',       '>= 1.2.0'
  
  s.add_development_dependency 'rdoc', '>= 2.4.1'
  s.add_development_dependency 'rake', '>= 0.8.3'

  s.has_rdoc = true
  s.homepage = "http://libraggi.rubyforge.org/async_sinatra"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Async Sinatra", "--main", "README.rdoc"]
  s.require_paths = %w[lib]
  s.rubyforge_project = 'libraggi'
  s.rubygems_version = '1.3.1'
end
