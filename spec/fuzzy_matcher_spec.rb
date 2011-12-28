require 'spec_helper'

describe FuzzyMatcher do
  before do
    @specs = []
  end

  def spec(name, version='1.2')
    spec = Gem::Specification.new
    spec.name = name
    spec.version = version
    @specs << spec
    spec
  end

  describe "#matches" do
    describe "when no version is given" do
      before do
        @matcher = FuzzyMatcher.new('name', nil)
      end

      describe "when there are specs whose name matches the term exactly" do
        before do
          @name1 = spec('name')
          @name2 = spec('name')
        end

        it "should return the matching specs" do
          @matcher.matches(@specs).should == [@name1, @name2]
        end

        it "should not return any specs whose name only contains the term" do
          xnamex = spec('xnamex')
          @matcher.matches(@specs).should_not include(xnamex)
        end
      end

      describe "when there are no specs who name matches the term exactly, but there are specs whose name contains the term" do
        before do
          @aname = spec('aname')
          @nameb = spec('nameb')
        end

        it "should return any specs whose name contains the term" do
          @matcher.matches(@specs).should == [@aname, @nameb]
        end

        it "should not return any specs whose name only contains the term as a subsequence" do
          @nxame = spec('nxame')
          @matcher.matches(@specs).should_not include(@nxame)
        end
      end

      describe "when there are no specs whose name contains the term, but there are specs whose name contains the term as a subsequence" do
        before do
          @nxame = spec('nxame')
          @n_axxme = spec('n-axxme')
        end

        it "should return any specs whose name contains the term as a subsequence" do
          @matcher.matches(@specs).should == [@nxame, @n_axxme]
        end

        it "should not return any specs whose name does not contain the term as a subsequence" do
          @zzz = spec('zzz')
          @matcher.matches(@specs).should_not include(@zzz)
        end
      end

      describe "when there are no specs whose name contains the term as a subsequence" do
        it "should return no results" do
          spec('zzz')
          @matcher.matches(@specs).should == []
        end
      end
    end

    describe "when a version is given" do
      before do
        @matcher = FuzzyMatcher.new('name', '1.2')
      end

      describe "when there are specs whose version matches the term exactly" do
        before do
          @name1 = spec('name', '1.2')
          @name2 = spec('name', '1.2')
        end

        it "should return the matching specs" do
          @matcher.matches(@specs).should == [@name1, @name2]
        end

        it "should not return any specs whose version only contains the term" do
          v11 = spec('name', '1.2.3')
          @matcher.matches(@specs).should_not include(v11)
        end
      end

      describe "when there are no specs who version matches the term exactly, but there are specs whose version contains the term" do
        before do
          @v121 = spec('name', '1.2.1')
          @v122 = spec('name', '1.2.2')
        end

        it "should return any specs whose version contains the term" do
          @matcher.matches(@specs).should == [@v121, @v122]
        end

        it "should not return any specs whose version only contains the term as a subsequence" do
          v132 = spec('name', '1.3.2')
          @matcher.matches(@specs).should_not include(v132)
        end
      end

      describe "when there are no specs whose version contains the term, but there are specs whose version contains the term as a subsequence" do
        before do
          @v132 = spec('name', '1.3.2')
          @v142 = spec('name', '1.4.2')
        end

        it "should return any specs whose version contains the term as a subsequence" do
          @matcher.matches(@specs).should == [@v132, @v142]
        end

        it "should not return any specs whose version does not contain the term as a subsequence" do
          v45 = spec('name', '4.5')
          @matcher.matches(@specs).should_not include(v45)
        end
      end

      describe "when there are no specs whose version contains the term as a subsequence" do
        it "should return no results" do
          spec('name', '4.5')
          @matcher.matches(@specs).should == []
        end
      end

      it "should filter the specs whose name matches with the version" do
        name_only_match = spec('name', '4.5')
        version_only_match = spec('unmatched', '1.2')
        name_and_version_match = spec('name', '1.2')
        @matcher.matches(@specs).should == [name_and_version_match]
      end
    end
  end
end
