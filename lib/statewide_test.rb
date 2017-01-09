require_relative "../../headcount/lib/cleanup"
require_relative "../../headcount/lib/errors"

class StatewideTest
  include Cleanup
  attr_reader :name

  def initialize(attributes)
    @attributes = attributes
    @name = attributes[:name].upcase
    @attributes[:third_grade] ||= {}
    @attributes[:eighth_grade] ||= {}
    @attributes[:reading] ||= {}
    @attributes[:writing] ||= {}
    @attributes[:math] ||= {}
  end

  def add_third_grade(subject, year, data)
    if !@attributes[:third_grade].has_key?(year)
      @attributes[:third_grade][year] = {}
    end
    @attributes[:third_grade][year][subject] = data
  end

  def add_eighth_grade(subject, year, data)
    if !@attributes[:eighth_grade].has_key?(year)
      @attributes[:eighth_grade][year] = {}
    end
    @attributes[:eighth_grade][year][subject] = data
  end

  def add_math_data_for_race(ethnicity, year, data)
    if !@attributes[:math].has_key?(year)
      @attributes[:math][year]= {}
    end
    @attributes[:math][year][ethnicity] = data
  end

  def add_writing_data_for_race(ethnicity, year, data)
    if !@attributes[:writing].has_key?(year)
      @attributes[:writing][year]= {}
    end
    @attributes[:writing][year][ethnicity] = data
  end

  def add_reading_data_for_race(ethnicity, year, data)
    if !@attributes[:reading].has_key?(year)
      @attributes[:reading][year]= {}
    end
    @attributes[:reading][year][ethnicity] = data
  end

  def proficient_by_grade(grade_level)
    if grade_level == 3
      sanitize_nested_hash(@attributes[:third_grade])
    elsif grade_level == 8
      sanitize_nested_hash(@attributes[:eighth_grade])
    else
      raise UnknownDataError
    end
  end

  def check_race_validity(race)
    [:asian, :black, :pacific_islander, :hispanic, :native_american,
      :two_or_more, :white].include?(race)
    end

    def proficient_by_race_or_ethnicity(race)
      if check_race_validity(race)
        @attributes.reduce({}) do |memo, (name, files)|
          if ![:name, :third_grade, :eighth_grade].include?(name)
            race_proficiency = sanitize_nested_hash(@attributes[name])
            race_proficiency.each do |(year, data)|
              if data.has_key?(race)
                if !memo.has_key?(year)
                  memo[year] = {}
                end
                memo[year][name] = data[race]
              end
            end
          end
          memo
        end
      else
        raise UnknownRaceError
      end
    end

    def proficient_for_subject_by_grade_in_year(subject, grade_level, year)
      if !proficient_by_grade(grade_level).has_key?(year)
        raise UnknownDataError
      elsif !proficient_by_grade(grade_level)[year].has_key?(subject)
        raise UnknownDataError
      else
        proficient_by_grade(grade_level)[year][subject]
      end
    end

    def proficient_for_subject_by_race_in_year(subject, race, year)
      if !proficient_by_race_or_ethnicity(race).has_key?(year)
        raise UnknownDataError
      elsif !proficient_by_race_or_ethnicity(race)[year].has_key?(subject)
        raise UnknownDataError
      else
        proficient_by_race_or_ethnicity(race)[year][subject]
      end
    end

  end
