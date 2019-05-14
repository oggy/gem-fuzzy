ROOT = File.expand_path('..', File.dirname(__FILE__))
$:.unshift "#{ROOT}/lib"

require 'minitest/autorun'
require 'minitest/around/spec'
require 'gem_fuzzy'
