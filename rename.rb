#!/usr/bin/ruby
require './rename-core'
require './simple-replace'
require './argv-parser'

#スペースを繰り返す時はエスケープが必要かも
#when exists same filename, なんらかの対処

class Renamer < ARGVParser
	def initialize(argv)
		super(argv)
	end

	def parse
		self.all_parse
		p self.rename_option

		@pathes  = TargetPathes.new(self.directory, :file)
		@newword = NewWord.new(self.rename_option, @pathes.size)
	end

	def rename
		newnames = []
		@pathes.each do |name|
			newname = simple_replace(name, self.target, @newword.get)
			puts "#{name}  =>  #{newname}"
			newnames.push(newname)
		end

		puts "Rename these? (y/N)"
		case STDIN.gets.chomp
		when "Y", "y", "YES", "yes"
			@pathes.rename do |name|
				newnames.shift
			end
		end
	end
end

r = Renamer.new(ARGV)
r.parse
r.rename
