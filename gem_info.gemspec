$:.unshift File.expand_path('lib', File.dirname(__FILE__))
require 'gem_info/version'

Gem::Specification.new do |gem|
  gem.name = 'gem_info'
  gem.version = GemInfo::VERSION
  gem.author = "George Ogata"
  gem.email = 'george.ogata@gmail.com'
  gem.license = 'MIT'
  gem.date = Time.now.strftime('%Y-%m-%d')
  gem.summary = 'Print information about gems.'
  gem.description = <<-EOS.gsub(/^ *\|/, '')
    |A rubygems plugin which adds an 'info' command which prints
    |information about gems.
    |
    |Unlike the built-in gem commands, it allows fuzzy matching on gem
    |names and versions by default, and allows precise formatting of the
    |output, making it easy on the command line and in scripts.
  EOS
  gem.homepage = 'http://github.com/oggy/gem_info'

  gem.files = Dir['lib/**/*.rb', 'CHANGELOG', 'LICENSE', 'Rakefile', 'README.markdown']
  gem.test_files = Dir['spec/**/*.rb']

  gem.specification_version = 3
end
