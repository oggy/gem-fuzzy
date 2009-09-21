module GemInfo
  class Runner
    def self.run(options, *args)
      Runner.new(options, *args).run
    end

    def initialize(options={}, *args)
      @options = options
      @args = args
      @output = STDOUT
    end

    attr_accessor :options, :args, :output

    def run
      parse_args
      parse_options
      matcher = FuzzyMatcher.new(@name, @version)
      specs = matcher.matches(installed_specs)
      validate_exactly_one(specs)
      output_formatted(specs)
    end

    private  # ---------------------------------------------------------

    def parse_args
      case @args.length
      when 1
        @name, @version = @args.first, nil
      when 2
        @name, @version = *@args
      else
        raise UsageError
      end
    end

    def parse_options
      @format = options[:format] || "%name %version"
    end

    def installed_specs
      Gem.source_index.all_gems.values
    end

    def validate_exactly_one(specs)
      if @options[:exactly_one]
        if specs.empty?
          raise Error, "no gems matching \"#{@name}\" \"#{@version}\""
        elsif specs.length > 1
          message = "#{specs.length} matching gems:\n" +
            specs.map{|spec| "  #{spec.name}\n"}.join
          raise Error, message
        end
      end
    end

    def output_formatted(specs)
      specs.each do |spec|
        output.print format(spec)
        output.print "\n" unless options[:no_newlines]
      end
    end

    def format(spec)
      @format.gsub(format_regexp) do |match|
        if match =~ /\A%date/
          expansion = expand_date(spec, match)
        else
          self.class.expansions[match].call(spec)
        end
      end
    end

    def expand_date(spec, match)
      date = spec.date
      if match =~ /\[(.*)\]/
        date.strftime($1)
      else
        date.to_s
      end
    end

    def format_regexp
      @format_regexp ||= Regexp.union(*self.class.expansions.keys)
    end

    class << self
      def expand(token, &expansion)
        @expansions ||= {}
        expansions[token] = expansion
      end
      attr_reader :expansions
    end

    expand('%rubygems_version'){|spec| spec.rubygems_version}
    expand('%specification_version'){|spec| spec.specification_version}
    expand('%name'){|spec| spec.name}
    expand('%version'){|spec| spec.version}
    expand(/%date(?:\[.*?\])?/) # handled specially
    expand('%summary'){|spec| spec.summary}
    expand('%email'){|spec| spec.email}
    expand('%homepage'){|spec| spec.homepage}
    expand('%rubyforge_project'){|spec| spec.rubyforge_project}
    expand('%description'){|spec| spec.description}
    expand('%executables'){|spec| spec.executables.join(', ')}
    expand('%bindir'){|spec| spec.bindir}
    expand('%required_ruby_version'){|spec| spec.required_ruby_version}
    expand('%required_rubygems_version'){|spec| spec.required_rubygems_version}
    expand('%platform'){|spec| spec.platform}
    expand('%signing_key'){|spec| spec.signing_key}
    expand('%cert_chain'){|spec| Array(spec.cert_chain).join("\n\n")}
    expand('%post_install_message'){|spec| spec.post_install_message}
    expand('%authors'){|spec| spec.authors.join(', ')}
    expand('%licenses'){|spec| spec.licenses.join(', ')}
    expand('%dependencies'){|spec| spec.dependencies.map{|dep| "#{dep.name} #{dep.version_requirements}"}.join(', ')}
    expand('%path'){|spec| spec.full_gem_path}
    expand('%%'){|spec| '%'}
    expand('%N'){|spec| "\n"}
  end
end
