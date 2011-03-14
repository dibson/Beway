Gem::Specification.new do |s|
  s.name = "beway"
  s.summary = "Simple UI and library for using Ruby to access ebay"
  s.description = File.read(File.join(File.dirname(__FILE__), 'README'))
  s.requirements = [ 'Ruby >= 1.9, some ruby gems (see README)' ]
  s.version = "1.0.2"
  s.author = "Dibson T Hoffweiler"
  s.email = "dibson@hoffweiler.com"
  s.homepage = "http://www.hoffweiler.com/"

  s.platform = Gem::Platform::RUBY

  s.required_ruby_version = '>=1.9'
  s.add_dependency('nokogiri', '>=1.4.4')
  s.add_dependency('mechanize', '>=1.0.0')
  s.add_development_dependency('rspec')

  s.files = Dir[ 'bin/*' ] + Dir[ 'doc/**/*' ] + Dir[ 'lib/**/*.rb' ] + Dir[ '[A-Z]*' ] + Dir[ 'spec/**/*' ]
  s.require_paths = [ 'lib' ]
  s.executables = [ 'beway' ]
  s.default_executable = [ 'beway' ]
  s.has_rdoc = true
end
