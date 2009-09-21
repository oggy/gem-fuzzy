require 'rubygems/command_manager'
require 'gem_info'

Gem::CommandManager.instance.register_command :info

module Gem
  module Commands
    class InfoCommand < Command
      def initialize
        super 'info', "Print information about a gem.  Fuzzy matching available."
        add_option('-1', '--exactly-one', "Fail if not exactly 1 match.") do |value, options|
          options[:exactly_one] = true
        end
        add_option('-f', '--format STRING', "Format of output (see below).") do |value, options|
          options[:format] = value
        end
        add_option('-N', '--no-newlines', "Suppress printing of newlines after each gem") do |value, options|
          options[:no_newlines] = true
        end
      end

      def arguments
        <<-EOS.gsub(/^ *\|/, '')
          |NAME     (fuzzy) name of the gem
          |VERSION  (fuzzy) version of the gem
        EOS
      end

      def usage
        "#{program_name} NAME [VERSION]"
      end

      def default_str
        ''
      end

      def description
        <<-EOS.gsub(/^ *\|/, '')
          |Print information about matching gems.  The NAME and
          |VERSION are fuzzy-matched according to the following
          |algorithm:
          |
          | * Look for gems exactly matching NAME.
          | * If none found, look for gems containing NAME. e.g.,
          |   "inf" matches "gem_info"
          | * If none found, look for gems containing the characters
          |   of NAME in the same order.  e.g, "e_nf" matches
          |   "gem_info"
          | * Filter the results above with the version string in the
          |   same way.
          |
          |The format string (--format option) has the following
          |escapes available:
          |
          |%rubygems_version
          |  Rubygems version that built the gemspec
          |%specification_version
          |  Version of the gem's gemspec
          |%name
          |  Gem name
          |%version
          |  Gem version
          |%date
          |%date[STRFTIME_FORMAT]
          |  Date the gem was released. STRFTIME_FORMAT may contain
          |  any %-escapes honored by Time#strftime
          |%summary
          |  Summary of the gem
          |%email
          |  Email address of the gem author
          |%homepage
          |  Homepage of the gem
          |%rubyforge_project
          |  Name of the rubyforge project
          |%description
          |  Gem description
          |%executables
          |  List of executables (comma separated)
          |%bindir
          |  Directory the gem's executables are installed into
          |%required_ruby_version
          |  Ruby version required for the gem
          |%required_rubygems_version
          |  Rubygems version required for the gem
          |%platform
          |  Platform the gem is built for
          |%signing_key
          |  Key which signed the gem
          |%cert_chain
          |  Certificate chain used for signing ("\\n\\n" separated)
          |%post_install_message
          |  Message displayed upon installation
          |%authors
          |  List of author names (comma separated)
          |%licenses
          |  List of license names (comma separated)
          |%dependencies
          |  List of dependencies (comma separated)
          |%path
          |  Path of the installed gem
          |%%
          |  A '%' character
          |%N
          |  A newline
        EOS
      end

      def execute
        begin
          GemInfo::Runner.run(options, *options[:args])
        rescue GemInfo::UsageError
          STDERR.puts "USAGE: #{usage}"
          terminate_interaction(1)
        rescue GemInfo::Error => e
          STDERR.puts e.message
          terminate_interaction(1)
        rescue Object => e
          puts "Unexpected error!  Debug with DEBUG=1"
          if ENV['DEBUG']
            STDERR.puts "#{exception.class}: #{exception.message}"
            exception.backtrace.each do |line|
              STDERR.puts "  #{line}"
            end
          end
          raise
        end
      end
    end
  end
end
