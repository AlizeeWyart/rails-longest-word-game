require 'open-uri'
require 'json'
require 'Date'

class PagesController < ApplicationController

  def game
    array = []
    9.times { array << ('A'..'Z').to_a.sample }
    @start_time = Time.now.to_s
    @grid = array.join("")
  end

  def score
    # TEMPS
    @end_time = DateTime.parse(Time.now.to_s)
    @start_time = DateTime.parse(params[:start_time])
    @elapsed = ((@end_time - @start_time)*100000).to_i
    # REPONSES @ GRID
    @grid = params[:grid]
    @attempt = params[:attempt]
    # RESULTS
    @result = run_game(@attempt, @grid, @elapsed)
  end

  private

  def get_translate(word)
    url = "https://api-platform.systran.net/translation/text/translate?source="\
          "en&target=fr&key=fc7a0b99-1841-4c17-a4d0-0c491ff853f6&input=#{word}"
    t_word = JSON.parse(open(url).read)
    return t_word["outputs"][0]["output"]
  end

  def word_counter(sentence)
    histogram = Hash.new { 0 }
    sentence.to_s.upcase.split("").each do |word|
      histogram[word] += 1
    end
    return histogram
  end

  def check_inclusion?(attempt, grid)
    attempt_bis = Hash.new { 0 }
    word_counter(attempt).each do |letter, count|
      if word_counter(grid)[letter] && count <= word_counter(grid)[letter]
        attempt_bis[letter] = true
      else
        attempt_bis[letter] = false
      end
    end

    return !attempt_bis.value?(false)
  end

  # attempt.upcase.split("").all?{|letter| grid.include?(letter)}

  def run_game(attempt, grid, elapsed)
    h1 = { time: elapsed }
    tl = get_translate(attempt)
    if check_inclusion?(attempt, grid) && tl != attempt
      h2 = { translation: tl, score: attempt.length + (1 / elapsed), message: "well done" }
    elsif check_inclusion?(attempt, grid) && tl == attempt
      h2 = { translation: nil, score: 0, message: "not an english word" }
    else
      h2 = { translation: nil, score: 0, message: "not in the grid" }
    end
    return h1.merge(h2)
  end
end
