require 'spec_helper'

describe Runner do
  before do
    @runner = Runner.new({}, 'name', 'version')
    @runner.output = StringIO.new
  end

  def make_spec(name='NAME', version='1.2')
    spec = Gem::Specification.new
    spec.name = name
    spec.version = Gem::Version.create(version)
    spec
  end

  def output
    @runner.run
    @runner.output.string
  end

  describe "#initialize" do
    it "should raise a UsageError if no non-option arguments are given" do
      @runner.args = []
      lambda{@runner.run}.should raise_error(UsageError)
    end

    it "should raise a UsageError if more than 2 non-option arguments are given" do
      @runner.args = ['x', 'x', 'x']
      lambda{@runner.run}.should raise_error(UsageError)
    end
  end

  describe "when exactly one match is required" do
    before do
      @runner.options = {:exactly_one => true}
    end

    it "should raise an error if no matches are found" do
      FuzzyMatcher.any_instance.stubs(:matches).returns([])
      lambda{@runner.run}.should raise_error(Error)
    end

    it "should raise an error if more than one match is found" do
      FuzzyMatcher.any_instance.stubs(:matches).returns([make_spec, make_spec])
      lambda{@runner.run}.should raise_error(Error)
    end

    it "should not raise an error if one match is found" do
      FuzzyMatcher.any_instance.stubs(:matches).returns([make_spec])
      lambda{@runner.run}.should_not raise_error
    end
  end

  describe "when there are matching gems" do
    before do
      specs = [make_spec('ONE', '1.0'), make_spec('TWO', '2.0')]
      FuzzyMatcher.any_instance.stubs(:matches).returns(specs)
    end

    it "should print each gem name and version on its own line" do
      output.should == "ONE 1.0\nTWO 2.0\n"
    end

    describe "when newline printing is suppressed" do
      before do
        @runner.options[:no_newlines] = true
      end
      it "should not print newlines after each gem" do
        output.should == "ONE 1.0TWO 2.0"
      end
    end
  end

  describe "when exactly one match is not required" do
    it "should not raise an error if no matches are found" do
      FuzzyMatcher.any_instance.stubs(:matches).returns([])
      lambda{@runner.run}.should_not raise_error
    end
  end

  describe "when a format string is given" do
    def stub_matches(attributes={})
      spec = Gem::Specification.new
      attributes.each do |name, value|
        spec.stubs(name).returns(value)
      end
      FuzzyMatcher.any_instance.stubs(:matches).returns([spec])
    end

    it "should replace %rubygems_version with the version of rubygems used to create the gem" do
      stub_matches :rubygems_version => '10.0'
      @runner.options[:format] = '%rubygems_version'
      output.should == "10.0\n"
    end

    it "should replace %specification_version of the gem" do
      stub_matches :specification_version => '10.0'
      @runner.options[:format] = '%specification_version'
      output.should == "10.0\n"
    end

    it "should replace %name with the gem name" do
      stub_matches :name => 'NAME'
      @runner.options[:format] = '%name'
      output.should == "NAME\n"
    end

    it "should replace %version with the version" do
      stub_matches :version => Gem::Version.create('1.2.3')
      @runner.options[:format] = '%version'
      output.should == "1.2.3\n"
    end

    it "should replace %date with the release date in the default time format" do
      time = Time.mktime(2001, 2, 3, 4, 5, 6).utc
      stub_matches :date => time
      @runner.options[:format] = '%date'
      output.should == "#{time}\n"
    end

    it "should replace %date[%B] with the month of the release date" do
      stub_matches :date => Time.mktime(2001, 2, 3, 4, 5, 6).utc
      @runner.options[:format] = '%date[%B]'
      output.should == "February\n"
    end

    it "should replace %summary with the summary of the gem" do
      stub_matches :summary => 'SUMMARY'
      @runner.options[:format] = '%summary'
      output.should == "SUMMARY\n"
    end

    it "should replace %email with the email of the gem author" do
      stub_matches :email => 'EM@I.L'
      @runner.options[:format] = '%email'
      output.should == "EM@I.L\n"
    end

    it "should replace %homepage with the homepage of the gem" do
      stub_matches :homepage => 'http://example.com'
      @runner.options[:format] = '%homepage'
      output.should == "http://example.com\n"
    end

    it "should replace %rubyforge_project with the name of the Rubyforge project" do
      stub_matches :rubyforge_project => 'RUBYFORGE_PROJECT'
      @runner.options[:format] = '%rubyforge_project'
      output.should == "RUBYFORGE_PROJECT\n"
    end

    it "should replace %description with the description of the gem" do
      stub_matches :description => 'DESCRIPTION'
      @runner.options[:format] = '%description'
      output.should == "DESCRIPTION\n"
    end

    it "should replace %executables with the list of executables in the gem (comma-separated)" do
      stub_matches :executables => ['EXECUTABLE1',  'EXECUTABLE2']
      @runner.options[:format] = '%executables'
      output.should == "EXECUTABLE1, EXECUTABLE2\n"
    end

    it "should replace %bindir with the path for executable scripts of the gem" do
      stub_matches :bindir => 'BINDIR'
      @runner.options[:format] = '%bindir'
      output.should == "BINDIR\n"
    end

    it "should replace %required_ruby_version with the required ruby version for the gem" do
      stub_matches :required_ruby_version => '10.0'
      @runner.options[:format] = '%required_ruby_version'
      output.should == "10.0\n"
    end

    it "should replace %required_rubygems_version with the required rubygems version for the gem" do
      stub_matches :required_rubygems_version => '10.0'
      @runner.options[:format] = '%required_rubygems_version'
      output.should == "10.0\n"
    end

    it "should replace %platform with the platform the gem runs on" do
      stub_matches :platform => 'ruby'
      @runner.options[:format] = '%platform'
      output.should == "ruby\n"
    end

    it "should replace %signing_key with the key the gem was signed with" do
      stub_matches :signing_key => 'KEY'
      @runner.options[:format] = '%signing_key'
      output.should == "KEY\n"
    end

    it "should replace %cert_chain with the certificate chain used to sign the gem" do
      stub_matches :cert_chain => ['CERT_CHAIN']
      @runner.options[:format] = '%cert_chain'
      output.should == "CERT_CHAIN\n"
    end

    it "should handle specs with a nil cert_chain" do
      stub_matches :cert_chain => nil
      @runner.options[:format] = '%cert_chain'
      output.should == "\n"
    end

    it "should replace %post_install_message with the message displayed after the gem is installed" do
      stub_matches :post_install_message => 'POST_INSTALL_MESSAGE'
      @runner.options[:format] = '%post_install_message'
      output.should == "POST_INSTALL_MESSAGE\n"
    end

    it "should replace %authors with the list of gem authors (comma-separated)" do
      stub_matches :authors => ['John Smith', 'Mary Jane']
      @runner.options[:format] = '%authors'
      output.should == "John Smith, Mary Jane\n"
    end

    it "should replace %licenses with the license names of the gem (comma-separated)" do
      stub_matches :licenses => ['MIT', 'ruby']
      @runner.options[:format] = '%licenses'
      output.should == "MIT, ruby\n"
    end

    it "should replace %dependencies with the list of dependencies (comma-separated)" do
      dependency1 = Gem::Dependency.new('GEM1', '>= 1.0')
      dependency2 = Gem::Dependency.new('GEM2', '>= 2.0')
      stub_matches :dependencies => [dependency1, dependency2]
      @runner.options[:format] = '%dependencies'
      output.should == "GEM1 >= 1.0, GEM2 >= 2.0\n"
    end

    it "should replace %path with the path to the gem" do
      stub_matches :full_gem_path => '/path/to/gem'
      @runner.options[:format] = '%path'
      output.should == "/path/to/gem\n"
    end

    it "should replace %% with a '%'-sign" do
      stub_matches
      @runner.options[:format] = '%%'
      output.should == "%\n"
    end

    it "should replace %N with a newline" do
      stub_matches
      @runner.options[:format] = '%N'
      output.should == "\n\n"
    end
  end
end
