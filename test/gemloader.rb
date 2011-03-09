require 'rubygems'
begin
  project = File.basename(Dir['*.gemspec'].first, '.gemspec')
  gemspec = File.expand_path("#{project}.gemspec", Dir.pwd)
  spec = Gem::Specification.load(gemspec)
  (spec.dependencies + spec.development_dependencies).each do |dep|
    gem dep.name, dep.requirement.to_s
  end
rescue
  warn "#{__FILE__}: Can't preload project dependencies: #{$!}"
end
