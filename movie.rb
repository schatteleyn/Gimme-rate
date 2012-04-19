#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__)

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
	  result['person']['participation'].each do |participation|        
      if participation && (m = participation['movie']) && (r = m['release']) && (rs = r['releaseState']) && [nil, 3011].include?(rs['code']) then 
        next
      else
        title = participation['movie']['originalTitle']
        filmo.push(title)
      end
    end
    
    filmo.reverse!
    return filmo
  end

	filmo = getFilmography(name)
  marks = []
	
	filmo.each do |title|
	  note = mmc(title)
	  marks.push(note)
	end
	
	def graph(marks)
	  marks = marks.join(',')
	  puts "`spark` #{marks}"
	end
  
else
  $stderr.puts "You must install spark"
  Process.exit
end
