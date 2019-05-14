$:.unshift File.expand_path('lib', File.dirname(__FILE__))
require 'gem_fuzzy/version'

Gem::Specification.new do |gem|
  gem.name = 'gem-fuzzy'
  gem.version = GemFuzzy::VERSION
  gem.author = "George Ogata"
  gem.email = 'george.ogata@gmail.com'
  gem.license = 'MIT'
  gem.date = Time.now.strftime('%Y-%m-%d')
  gem.summary = 'Search for gems, fuzzily.'
  gem.description = <<-EOS.gsub(/^ *\|/, '')
    |A Rubygems plugin which adds a 'fuzzy' command which fuzzy-searches for
    |gems and prints information about each match.
    |
    |Options provide precise control over output format, making it friendly both
    |on the command line and in scripts.
  EOS
  gem.homepage = 'http://github.com/oggy/gem-fuzzy'

  gem.files = Dir['lib/**/*.rb', 'CHANGELOG', 'LICENSE', 'Rakefile', 'README.markdown']
  gem.test_files = Dir['spec/**/*.rb']

  gem.specification_version = 3
end
