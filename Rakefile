#!/usr/bin/env rake

require 'hoe'
Hoe.plugin :doofus, :git, :minitest, :gemspec2

Hoe.spec 'async_sinatra' do
  developer 'raggi', 'jftucker@gmail.com'
  license "MIT"

  extra_deps << %w[rack >=1.4.1]
  extra_deps << %w[sinatra >=1.3.2]

  extra_dev_deps << %w(rack-test)
  extra_dev_deps << %w(hoe-doofus >=1.0)
  extra_dev_deps << %w(hoe-seattlerb >=1.2)
  extra_dev_deps << %w(hoe-git >=1.3)
  extra_dev_deps << %w(hoe-gemspec2 >=1.0)
  extra_dev_deps << %w(rdoc)
  extra_dev_deps << %w(eventmachine >=0.12.11)

  self.extra_rdoc_files = FileList["**/*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"
end
