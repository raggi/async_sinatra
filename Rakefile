#!/usr/bin/env rake
task :default => :spec

def spec(file = Dir['*.gemspec'].first)
  @spec ||=
  begin
    require 'rubygems/specification'
    Thread.abort_on_exception = true
    data = File.read(file)
    spec = nil
    Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
    spec.instance_variable_set(:@filename, file)
    def spec.filename; @filename; end
    spec
  end
end

def manifest; @manifest ||= `git ls-files`.split("\n").reject{|s|s=~/\.gemspec$|\.gitignore$/}; end

require 'rake/gempackagetask'
def gem_task; @gem_task ||= Rake::GemPackageTask.new(spec); end
gem_task.define

require 'rake/testtask'
Rake::TestTask.new(:spec) do |t|
  t.test_files = spec.test_files
  t.ruby_opts = ['-rubygems'] if defined? Gem
  t.warning = true
end unless spec.test_files.empty?

require 'rake/rdoctask'
df = begin; require 'rdoc/generator/darkfish'; true; rescue LoadError; end
rdtask = Rake::RDocTask.new do |rd|
  rd.title = spec.name
  rd.main = spec.extra_rdoc_files.first
  rd.rdoc_files.include(manifest.grep(/\.rb$|\.rdoc$/), *spec.extra_rdoc_files)
  rd.template = 'darkfish' if df
end
Rake::Task[:clobber].enhance [:clobber_rdoc]

require 'etc'
require 'rake/contrib/rubyforgepublisher'
desc "Publish rdoc to rubyforge"
task :publish => rdtask.name do
  pub = Rake::RubyForgePublisher.new(
    "#{spec.rubyforge_project}/#{spec.name}", Etc.getlogin
  )
  pub.upload
end

desc 'Generate and open documentation'
task :docs => :rdoc do
  path = rdtask.send :rdoc_target
  case RUBY_PLATFORM
  when /darwin/       ; sh "open #{path}"
  when /mswin|mingw/  ; sh "start #{path}"
  else 
    sh "firefox #{path}"
  end
end

desc "Regenerate gemspec"
file spec.filename => FileList[*manifest] do
  spec.files = manifest
  spec.test_files = manifest.grep(/(?:spec|test)\/*.rb/)
  open(spec.filename, 'w') { |w| w.write spec.to_ruby }
end

desc "Bump version from #{spec.version} to #{spec.version.to_s.succ}"
task :bump do
  spec.version = spec.version.to_s.succ
end

desc "Tag version #{spec.version}"
task :tag do
  tagged = Dir['.git/refs/tags/*'].include? spec.version
  if tagged
    warn "Tag #{spec.version} already exists"
  else
    # TODO release message in tag message
    sh "git tag #{spec.version}"
  end
end

desc "Release #{gem_task.gem_file} to rubyforge"
task :release => [:tag, gem_task.gem_file] do |t|
  sh "rubyforge add_release #{spec.rubyforge_project} #{spec.name} #{spec.version} #{gem_task.gem_file}"
end