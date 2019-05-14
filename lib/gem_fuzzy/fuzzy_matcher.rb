module GemFuzzy
  class FuzzyMatcher
    def initialize(name, version)
      @name = name
      @version = version
    end

    def all_available_matches
      matches([])
    end

    def matches(specs)
      specs = matches_for(specs, :name, @name)
      specs = matches_for(specs, :version, @version) if @version
      specs
    end

    def matches_for(specs, attribute, value)
      [:exact, :substring, :subsequence].each do |type|
        matches = send("#{type}_matches", specs, attribute, value)
        return matches if !matches.empty?
      end
      []
    end

    private

    def exact_matches(specs, attribute, value)
      specs.select{|spec| spec.send(attribute).to_s == value}
    end

    def substring_matches(specs, attribute, value)
      specs.select{|spec| spec.send(attribute).to_s.include?(value)}
    end

    def subsequence_matches(specs, attribute, value)
      specs.select{|spec| include_subsequence?(spec.send(attribute).to_s, value)}
    end

    def include_subsequence?(string, subsequence)
      string_index = 0
      subsequence_index = 0
      while string_index < string.length
        if string[string_index] == subsequence[subsequence_index]
          subsequence_index += 1
          return true if subsequence_index == subsequence.length
        end
        string_index += 1
      end
      return false
    end
  end
end
