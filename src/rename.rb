require './utils'
require './rename-core'
Version = 2.0

#get options
opt = argv_parse

#emnurate_targets
pathes = get_pathes(opt)

# show rename condidate and get this.
bf_pairs = get_before_after(opt, pathes)

puts 'Rename these? (y/N)'
if /^(Y|YES)$/i =~ STDIN.gets.to_s.chomp
  bf_pairs.each {|pair| recursive_rename(pair) }
end
