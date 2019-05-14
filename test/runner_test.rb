require_relative 'test_helper'

describe GemInfo::Runner do
  before do
    @runner = GemInfo::Runner.new({}, 'mygem', '1.2')
    @runner.output = StringIO.new
  end

  def stub_specs(specs, &block)
    @runner.stub(:installed_specs, specs, &block)
  end

  def make_spec(name, version)
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
      lambda{@runner.run}.must_raise GemInfo::UsageError
    end

    it "should raise a UsageError if more than 2 non-option arguments are given" do
      @runner.args = ['x', 'x', 'x']
      lambda{@runner.run}.must_raise GemInfo::UsageError
    end
  end

  describe "when exactly one match is required" do
    before do
      @runner.options = {:exactly_one => true}
    end

    it "should raise an error if no matches are found" do
      stub_specs [] do
        lambda{@runner.run}.must_raise GemInfo::Error
      end
    end

    it "should raise an error if more than one match is found" do
      stub_specs [make_spec('mygem1', '1.2'), make_spec('mygem2', '1.2')] do
        lambda{@runner.run}.must_raise GemInfo::Error
      end
    end

    it "should not raise an error if one match is found" do
      stub_specs [make_spec('mygem', '1.2')] do
        @runner.run
      end
    end
  end

  describe "when there are matching gems" do
    around do |test|
      stub_specs [make_spec('mygem1', '1.2.3'), make_spec('mygem2', '1.2.4')] do
        test.call
      end
    end

    it "should print each gem name and version on its own line" do
      output.must_equal "mygem1 1.2.3\nmygem2 1.2.4\n"
    end

    describe "when newline printing is suppressed" do
      before do
        @runner.options[:no_newlines] = true
      end

      it "should not print newlines after each gem" do
        output.must_equal "mygem1 1.2.3mygem2 1.2.4"
      end
    end
  end

  describe "when exactly one match is not required" do
    it "should not raise an error if no matches are found" do
      stub_specs [] do
        @runner.run
      end
    end
  end

  describe "when a format string is given" do
    def stub_one_match_having(attribute, value, &block)
      spec = make_spec('mygem', '1.2')
      spec.stub(attribute, value) do
        stub_specs([spec], &block)
      end
    end

    it "should replace %rubygems_version with the version of rubygems used to create the gem" do
      stub_one_match_having :rubygems_version, '10.0' do
        @runner.options[:format] = '%rubygems_version'
        output.must_equal "10.0\n"
      end
    end

    it "should replace %specification_version of the gem" do
      stub_one_match_having :specification_version, '10.0' do
        @runner.options[:format] = '%specification_version'
        output.must_equal "10.0\n"
      end
    end

    it "should replace %name with the gem name" do
      stub_specs [make_spec('mygem', '1.2')] do
        @runner.options[:format] = '%name'
        output.must_equal "mygem\n"
      end
    end

    it "should replace %version with the version" do
      stub_one_match_having :version, Gem::Version.create('1.2.3') do
        @runner.options[:format] = '%version'
        output.must_equal "1.2.3\n"
      end
    end

    it "should replace %date with the release date in the default time format" do
      time = Time.mktime(2001, 2, 3, 4, 5, 6).utc
      stub_one_match_having :date, time do
        @runner.options[:format] = '%date'
        output.must_equal "#{time}\n"
      end
    end

    it "should replace %date[%B] with the month of the release date" do
      stub_one_match_having :date, Time.mktime(2001, 2, 3, 4, 5, 6).utc do
        @runner.options[:format] = '%date[%B]'
        output.must_equal "February\n"
      end
    end

    it "should replace %summary with the summary of the gem" do
      stub_one_match_having :summary, 'SUMMARY' do
        @runner.options[:format] = '%summary'
        output.must_equal "SUMMARY\n"
      end
    end

    it "should replace %email with the email of the gem author" do
      stub_one_match_having :email, 'EM@I.L' do
        @runner.options[:format] = '%email'
        output.must_equal "EM@I.L\n"
      end
    end

    it "should replace %homepage with the homepage of the gem" do
      stub_one_match_having :homepage, 'http://example.com' do
        @runner.options[:format] = '%homepage'
        output.must_equal "http://example.com\n"
      end
    end

    it "should replace %description with the description of the gem" do
      stub_one_match_having :description, 'DESCRIPTION' do
        @runner.options[:format] = '%description'
        output.must_equal "DESCRIPTION\n"
      end
    end

    it "should replace %executables with the list of executables in the gem (comma-separated)" do
      stub_one_match_having :executables, ['EXECUTABLE1',  'EXECUTABLE2'] do
        @runner.options[:format] = '%executables'
        output.must_equal "EXECUTABLE1, EXECUTABLE2\n"
      end
    end

    it "should replace %bindir with the path for executable scripts of the gem" do
      stub_one_match_having :bindir, 'BINDIR' do
        @runner.options[:format] = '%bindir'
        output.must_equal "BINDIR\n"
      end
    end

    it "should replace %required_ruby_version with the required ruby version for the gem" do
      stub_one_match_having :required_ruby_version, '10.0' do
        @runner.options[:format] = '%required_ruby_version'
        output.must_equal "10.0\n"
      end
    end

    it "should replace %required_rubygems_version with the required rubygems version for the gem" do
      stub_one_match_having :required_rubygems_version, '10.0' do
        @runner.options[:format] = '%required_rubygems_version'
        output.must_equal "10.0\n"
      end
    end

    it "should replace %platform with the platform the gem runs on" do
      stub_one_match_having :platform, 'ruby' do
        @runner.options[:format] = '%platform'
        output.must_equal "ruby\n"
      end
    end

    it "should replace %signing_key with the key the gem was signed with" do
      stub_one_match_having :signing_key, 'KEY' do
        @runner.options[:format] = '%signing_key'
        output.must_equal "KEY\n"
      end
    end

    it "should replace %cert_chain with the certificate chain used to sign the gem" do
      stub_one_match_having :cert_chain, ['CERT_CHAIN'] do
        @runner.options[:format] = '%cert_chain'
        output.must_equal "CERT_CHAIN\n"
      end
    end

    it "should handle specs with a nil cert_chain" do
      stub_one_match_having :cert_chain, nil do
        @runner.options[:format] = '%cert_chain'
        output.must_equal "\n"
      end
    end

    it "should replace %post_install_message with the message displayed after the gem is installed" do
      stub_one_match_having :post_install_message, 'POST_INSTALL_MESSAGE' do
        @runner.options[:format] = '%post_install_message'
        output.must_equal "POST_INSTALL_MESSAGE\n"
      end
    end

    it "should replace %authors with the list of gem authors (comma-separated)" do
      stub_one_match_having :authors, ['John Smith', 'Mary Jane'] do
        @runner.options[:format] = '%authors'
        output.must_equal "John Smith, Mary Jane\n"
      end
    end

    it "should replace %licenses with the license names of the gem (comma-separated)" do
      stub_one_match_having :licenses, ['MIT', 'ruby'] do
        @runner.options[:format] = '%licenses'
        output.must_equal "MIT, ruby\n"
      end
    end

    it "should replace %dependencies with the list of dependencies (comma-separated)" do
      dependency1 = Gem::Dependency.new('GEM1', '>= 1.0')
      dependency2 = Gem::Dependency.new('GEM2', '>= 2.0')
      stub_one_match_having :dependencies, [dependency1, dependency2] do
        @runner.options[:format] = '%dependencies'
        output.must_equal "GEM1 >= 1.0, GEM2 >= 2.0\n"
      end
    end

    it "should replace %path with the path to the gem" do
      stub_one_match_having :full_gem_path, '/path/to/gem' do
        @runner.options[:format] = '%path'
        output.must_equal "/path/to/gem\n"
      end
    end

    it "should replace %% with a '%'-sign" do
      stub_specs [make_spec('mygem', '1.2')] do
        @runner.options[:format] = '%%'
        output.must_equal "%\n"
      end
    end

    it "should replace %N with a newline" do
      stub_specs [make_spec('mygem', '1.2')] do
        @runner.options[:format] = '%N'
        output.must_equal "\n\n"
      end
    end
  end
end
