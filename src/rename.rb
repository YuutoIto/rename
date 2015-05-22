require './utils'
require "./rename-core"
Version = 2.0

#get options
opt = argv_parse

#emnurate_targets
pathes = enum_targets(opt)


class Renamer < ARGVParser
	def initialize(argv)
    super(argv)
	end

	def parse
		self.all_parse
		@pathes  = TargetPathes.new(self.directory, :file)
		@newword = NewWord.new(self.rename_option, @pathes.size)
	end

	def rename
		@pathes.set_name_pair do |oldname|
			newname = simple_replace(oldname, self.target, @newword)
			newname = oldname if newname.empty?

			oldname = sprintf("%-32s", oldname) #インデントを揃える
			puts "#{oldname}  =>  #{newname}"
			next newname
		end

		puts "Rename these? (y/N)"
		case STDIN.gets.chomp
		when /Y/i, /YES/i
			@pathes.apply_name_pair
		end
	end
end

##renamer entry point
r = Renamer.new(ARGV)
r.parse
r.rename
