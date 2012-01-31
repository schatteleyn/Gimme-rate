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

# Method for converting fractions to decimals. Used below in "calculate_average" method.
def frac_to_float(str)
    numerator, denominator = str.split("/").map(&:to_f)
    denominator ||= 1
    numerator/denominator
end

def identify_movie(title) 
  def search(title)  
    url = "http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=#{APIKEY}&q=#{title}&page_limit=20"
    buffer = open(url).read

    # convert JSON data into a hash
    result = JSON.parse(buffer)
  end

  #Format and produce the search output
  def search_output(movie_list)
    count = 0
    movie_list["movies"].each do |h| 
      print "#{count}) "
       if count <10
         print " " #Ensure that first column is 2 spaces wide
       end
      print "Title: #{h["title"]}"
       if h["title"].length < 70
         print " "*(70-h["title"].length) #Ensure that first column is 70 spaces wide
       end
      print "Year: #{h["year"]}"
      print "\n"
      count += 1
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

  def display_final_stats(movie_critics, score_only)
    sum = 0
    count = 0
    movie_critics["reviews"].each_with_index do |a, index| 
      if a["original_score"] 
        unless score_only
          puts "#{index}) "
          puts "Critic: #{a["critic"]}"
          puts "Original Score: #{a["original_score"]}"
        end 

        converted_score = score_convert(a["original_score"])
        puts "Converted Score: #{converted_score}" unless score_only
        sum += converted_score 
        
        unless score_only
          puts "Quote: #{a["quote"]}"
          print "\n"
        end 
        count += 1
      end
    end
    
    #Calculates average converted score, for all RT critics
    avg_converted_score = ((sum.to_f)/count)
    print "\n"
    printf("Rotten tomatoes: %.2f", "#{avg_converted_score}")
    print "\n"
    return avg_converted_score
  end 
  
  # RUN FUNCTIONS #
  movie_found = get_movie(id) #movie_found is a hash that has the basic movie info
  movie_critics = get_all_critics(id) 
  show_movie_details_score = display_final_stats(movie_critics, score_only) 
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
  
  #Print out basic info (not individual critics reviews)
  print "IMDB Rating: ", movie_found["Rating"], "\n\n"
  return (movie_found["Rating"].to_f)*10
end

def metacritic(title)
  #insert metacritic scraping here
  movie = Nokogiri::HTML(open("http://www.metacritic.com/movie/#{title}"))
  rating = movie.at_css(".score_value").text
  print "Metacritic: ", rating, "\n"
  return rating
end 
  
temp = in_theaters  

#Ask user to enter a title
print "Movie title (search entire Rotten Tomatoes database): "
title = gets #take in movie title from command line
title.chomp!.gsub!(' ', '+') # sub spaces for plus signs

#Find the movie, based on the user's input
movie = identify_movie(title)

#Reformat the title, so IMDB and MC will recognize it
title_for_imdb = movie["title"].downcase.gsub(" ", "+")
title_for_mc = movie["title"].downcase.gsub(" ", "-")

#Use ID to find the movie in RT
id = movie["id"]

#Run the 3 main functions for RT, IMDB, and MC
rt_score = rt(id) 
mc_score = metacritic(title_for_mc).to_i
imdb_score = imdb(title_for_imdb) 

meta_meta_score = (rt_score + mc_score + imdb_score)/3.0
printf("Meta-metascore: %.2f", meta_meta_score)
print "\n\n"