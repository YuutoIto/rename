#!/usr/bin/ruby
require './rename-core'
require './simple-replace'
require './argv-parser'

=begin
スペースを繰り返す時はエスケープが必要かも
-n　を使った時文字列がマッチしなかった場合にもカウントアップされちゃう
	gsubで複数マッチした時に同じファイルでは同じ数値を使用するように呼び出し時にgetを使用しているけれど
	それをやめて@newwordオブジェクトを渡してgusbのブロックで実行させれば空読みがなくなるはず
	
=end

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
			newname = simple_replace(oldname, self.target, @newword.str)
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

r = Renamer.new(ARGV)
r.parse
r.rename
