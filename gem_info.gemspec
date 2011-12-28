$:.unshift File.expand_path('lib', File.dirname(__FILE__))
require 'gem_info/version'

Gem::Specification.new do |s|
  s.name = 'gem_info'
  s.version = GemInfo::VERSION
  s.author = "George Ogata"
  s.email = 'george.ogata@gmail.com'
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'Print information about gems.'
  s.description = <<-EOS.gsub(/^ *\|/, '')
    |A rubygems plugin which adds an 'info' command which prints
    |information about gems.
    |
    |Unlike the built-in gem commands, it allows fuzzy matching on gem
    |names and versions by default, and allows precise formatting of the
    |output, making it easy on the command line and in scripts.
  EOS
  s.homepage = 'http://github.com/oggy/gem_info'

  s.files = Dir['lib/**/*.rb', 'CHANGELOG', 'LICENSE', 'Rakefile', 'README.markdown']
  s.test_files = Dir['spec/**/*.rb']

  s.specification_version = 3
  s.add_development_dependency 'ritual', '~> 0.3.0'
  s.add_development_dependency 'rspec', '~> 2.7.0'
  s.add_development_dependency 'mocha'
end
