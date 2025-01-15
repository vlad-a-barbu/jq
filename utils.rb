require 'json'
require 'damerau-levenshtein'

def json_err(path)
  return :invalid_path unless File.exist?(path)
  JSON.parse(File.read(path))
rescue StandardError
  return :invalid_json
end

def json(path)
  res = json_err(path)
  case res
  when :invalid_path
    puts 'error: invalid file path'
    exit(1)
  when :invalid_json
    puts 'error: invalid json file format'
    exit(1)
  else
    res
  end
end

class SimilarityIndex
  MIN_SIMILARITY_PERCENT = 70.0

  attr_reader :similarity_idx, :words

  def initialize word1, word2
    @words = word1, word2
    similar?
  end
  
  def edit_distance
    DamerauLevenshtein.distance *@words
  end

  def longest_word_length
    @words.max_by(&:length).size
  end

  def similar?
    e = edit_distance
    l = longest_word_length.to_f
    @similarity_idx = ((1 - (e/l)) * 100).round 2
    @similarity_idx >= MIN_SIMILARITY_PERCENT
  end
end

class Hash  
  def query(q)
    matches = self.keys()
      .map  { similarity(it, q) }
      .sort { |x, y| y[:simid] - x[:simid] }
    key = matches[0][:key]
    { key:, value: self[key] }
  end

  private

  def similarity(key, q)
    { key:, simid: SimilarityIndex.new(key.downcase, q.downcase).similarity_idx }
  end
end
