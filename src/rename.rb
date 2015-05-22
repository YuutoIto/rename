require './utils'
require "./rename-core"
Version = 2.0


#get options
opt = argv_parse

#emnurate_targets
pathes = get_pathes(opt)

# show rename condidate and get this.
bf_pairs = get_before_after(opt, pathes)

puts "Rename these? (y/N)"
case STDIN.gets.chomp
when /^Y$/i, /^YES$/i
  bf_pairs.each do |before, after|
    File.rename(before, after)
  end
end
