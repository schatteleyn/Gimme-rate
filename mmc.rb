=begin
MetaMetaCritic is originally coded by jyli7. See the repo at https://github.com/jyli7/Meta-metacritic.
I'm currently refactoring the code to match my need.
=end

#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'open-uri'
require 'nokogiri'

APIKEY = "hv4pzbs4n46nmv7s9w87nzwu"

#def mmc(title)
# Method for converting fractions to decimals. Used below in "calculate_average" method.
def frac_to_float(str)
    numerator, denominator = str.split("/").map(&:to_f)
    denominator ||= 1
    numerator/denominator
end

def identify_movie(title) 
  url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=#{APIKEY}&q=#{title}&page_limit=20"
  buffer = open(url).read   
  # convert JSON data into a hash
  result = JSON.parse(buffer)
  result['movies'].each do |movie|
    if movie['title'] == title
      return movie
    end
  end
end

def rt(id)

    def get_movie(id)
        url = "http://api.rottentomatoes.com/api/public/v1.0/movies/#{id}.json?apikey=#{APIKEY}"
        buffer = open(url).read
        # convert JSON data into a hash
        result = JSON.parse(buffer)
        return result
    end

    # Pull up reviewers list

    def get_all_critics(id)
      url = "http://api.rottentomatoes.com/api/public/v1.0/movies/#{id}/reviews.json?review_type=all&page_limit=30&page=1&country=us&apikey=#{APIKEY}"
      buffer = open(url).read
      # convert JSON data into a hash
      result = JSON.parse(buffer)
      return result
    end 

    #Converts critic ratings, e.g. "A", "5/5", "78/100", to a 100 point scale
    def score_convert(n) 
        score = 0
        if n.length <= 2 #if the score is in "A", "A+", "C-" form
            case n[0] #to account for the first letter
            when "A"
            score = 95
            when "B"
            score = 85
            when "C"
            score = 75
            when "D"
            score = 65
            else
            score = 50
            end
        
            case n[1] #to account for + and -
            when "+"
            score += 3
            when "-"
            score -=3
            end
        end 
        if n.include? "/"  #if the score is in X/Y form
            score = (frac_to_float(n)*100).to_i
        end
        score
    end

    def display_final_stats(movie_critics)
        sum = 0
        count = 0
        movie_critics["reviews"].each_with_index do |a, index| 
            if a["original_score"] 
            converted_score = score_convert(a["original_score"])
            sum += converted_score 
            
            count += 1
            end
        end
        
        #Calculates average converted score, for all RT critics
        avg_converted_score = ((sum.to_f)/count)
        return avg_converted_score
    end 
    
    # RUN FUNCTIONS #
    movie_found = get_movie(id) #movie_found is a hash that has the basic movie info
    movie_critics = get_all_critics(id) 
    show_movie_details_score = display_final_stats(movie_critics) 
end 

def imdb(title) #returns the movie that the user selected

    def get_movie(title)
    url = "http://www.imdbapi.com/?i=&t=#{title}"
    buffer = open(url).read

    # convert JSON data into a hash
    result = JSON.parse(buffer)
    return result
    end

    movie_found = get_movie(title) #movie_found is a hash that has the basic movie info
    return (movie_found["Rating"].to_f)*10
end

def metacritic(title)
    #insert metacritic scraping here
    movie = Nokogiri::HTML(open("http://www.metacritic.com/movie/#{title}"))
    rating = movie.at_css(".score_value").text
    return rating
end 
    
#temp = in_theaters  

#Get the title
puts "Film"
title = gets
title.chomp!.gsub!(' ', '+') # sub spaces for plus signs

#Find the movie, based on the user's input
movie = identify_movie(title)

#Reformat the title, so IMDB and MC will recognize it
title_for_imdb = movie[0]["title"].downcase.gsub(" ", "+")
title_for_mc = movie[0]["title"].downcase.gsub(" ", "-")

#Use ID to find the movie in RT
id = movie[0]["id"]

#Run the 3 main functions for RT, IMDB, and MC
puts rt_score = rt(id) 
puts mc_score = metacritic(title_for_mc).to_i
puts imdb_score = imdb(title_for_imdb) 

meta_meta_score = ("%.2f" % ((rt_score + mc_score + imdb_score)/3.0))
puts meta_meta_score
#end
