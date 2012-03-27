#!/usr/bin/env ruby

require 'Net/http'
require 'json'
require 'mmc.rb'

if ENV["PATH"].split(':').any? {|x| FileTest.executable? "#{x}/spark" }
  
  puts "Your research: "
	name = gets.chomp.gsub(' ', '+').to_s.downcase

	def getFilmography(name)
	  query = "http://api.allocine.fr/rest/v3/search?partner=YW5kcm9pZC12M3M&filter=person&q=#{name}&format=json"
	  resp = Net::HTTP.get_response(URI.parse(query))
	  data = resp.body
	  result = JSON.parse(data)
	  result['feed']['person'].each { |person| @id = person['code'] }
	  if @id == nil
	    puts "Can't find this person"
	  end 
	
	  filmo = []
	
	  query = "http://api.allocine.fr/rest/v3/filmography?partner=YW5kcm9pZC12M3M&profile=medium&code=#{@id}&filter=movie&format=json"
	  resp = Net::HTTP.get_response(URI.parse(query))
	  data = resp.body
	  result = JSON.parse(data)
	  base_result = result['person']['participation']['movie']
	  
	  base_result.each do |base_result|
	    if base_resul['release']['releaseState']['code'] == '3011' || base_resul['release']['releaseState']['code'] == 'nil'
	      next
	    else
	      title = base_result['originalTitle']
	      filmo.push(title)
	    end
	  end
	  filmo = filmo.reverse
	  return filmo
	end

	filmo = getFilmography(name)
  marks = []

	filmo.each do |title|
	  note = mmc(title)
	  marks.push
	end
	
	def graph(marks)
	  marks = marks.join(',')
	  puts "`spark` #{marks}"
	end
  
else
  $stderr.puts "You must install spark"
  Process.exit
end
