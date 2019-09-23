require 'classifier-reborn'
require 'json'

def get_permalink(post_content)
   return post_content.match("permalink: (.*)$").captures[0]
end

lsi = ClassifierReborn::LSI.new

Dir["./_posts/*.markdown"].each do |post|
	print("Adding #{post} to classifer\n")
	lsi.add_item File.read(post)
end

print("Finished preprocessing the posts.\n\n")

recommendations = Hash.new

Dir["./_posts/*.markdown"].each do |post|
	print("Finding posts related to: #{post}\n")

	file = File.read(post)
	matches = lsi.find_related(file, 4).map { |content|
		content.match("permalink: (.*)$").captures[0]
	}

	recommendations[get_permalink(file)] = matches
end

File.open("./_data/recommendations.json","w") do |f|
  f.write(JSON.pretty_generate(recommendations))
end
