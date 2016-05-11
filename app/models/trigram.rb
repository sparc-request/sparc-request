# Model required by Fuzzily, the fuzzy searcher
class Trigram < ActiveRecord::Base
  include Fuzzily::Model
end
