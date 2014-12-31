require "./argv-parser.rb"

class RenameRoutineError  < StandardError; end      #code bug
class RenameStandardError < RenameRoutineError; end #この例外を補足する

class TargetPathes

	#ブロックを渡すとそのままリネームが実行できる
	def initialize(dir_path, mode)
		fail RenameStandard, "#{dir_path} not exists" unless Dir.exists?(dir_path)

		@pathes = Dir.glob(File.join(dir_path, "*"))
		return if @pathes.empty?
	
		case mode
		when :all
		when :file
			@pathes.select!{ |elem| File.file?(elem) }
		when :dir
			@pathes.select!{ |elem| File.directory?(elem) }
		else
			raise RenameRoutineError, "#{mode} is invalid mode, can use :all, :file, :dir"
		end

		#そのままリネーム
		return unless block_given?
		self.rename {|name| yield name }
	end

	#ブロック変数としてファイル名|ディレクトリ名を渡す
	#ブロック内でファイル名|ディレクトリ名を変更して関数に戻す
	def rename(&block)
		@pathes.each do |path|
			newname = block.call(File.basename(path))
			newpath = File.join(File.dirname(path), newname)
			File.rename(path, newpath);	
		end
	end

	def each(&block)
		@pathes.each {|path| block.call(File.basename(path)) }
	end

	def size
		@pathes.size
	end

end

class String
	def integer
		return Integer(self.sub(/^0*(.)/, '\1'))
	rescue 
		raise OptionFormatError, %Q["#{self}" can't convert to Integer]
	end
end

class Countup
	def initialize(opt_arg, path_num)
		opt_arg = "0" if opt_arg.nil?
		@count  = opt_arg.integer
		@digit  = opt_arg.size
		
		@digit  = Math.log10(path_num+@count).ceil if max-@count < path_num
	end

	def max
		10**@digit-1
	end

	def str
		fail RenameRoutineError, "count over the digit" if max < @count
		@count += 1
		return sprintf("%0#{@digit}d", @count-1)
	end
end

class NewWord
	def initialize(rename_opt, path_num)
		case rename_opt[:mode]
		when :replace, :erase
			@word_generator = lambda{ rename_opt[:arg] }
		when :number
			@count = Countup.new(rename_opt[:arg], path_num)
			@word_generator = lambda{ @count.str }
		else
			fail OptionFormatError, "#{rename_opt} isn't mode"
		end
	end

	def get
		@word_generator.call
	end
end
