require "./argv-parser.rb"

class RenameRoutineError  < StandardError; end      #code bug
class RenameStandardError < RenameRoutineError; end #この例外を補足する

class String
	def integer
		return Integer(self.sub(/^0*(.)/, '\1'))
	rescue 
		raise OptionFormatError, %Q["#{self}" can't convert to Integer]
	end

	def join(path)
		File.join(self, path)
	end
end

class TargetPathes
	def initialize(dir_path, mode)
		fail RenameStandard, "#{dir_path} not exists" unless Dir.exists?(dir_path)

		@names = Dir.glob(dir_path.join("*"))
		return if @names.empty?
	
		case mode
		when :all
		when :file
			@names.reject!{ |name| !File.file?(name) }
		when :dir
			@names.reject!{ |name| !File.directory?(name) }
		else
			raise RenameRoutineError, "#{mode} is invalid mode, can use :all, :file, :dir"
		end
		
		@names.map!{ |name| File.basename(name) }
		@names.sort!
		@DIR_NAME = dir_path
	end

	def each(&block)
		@names.each{ |oldname| block.call(oldname) }
	end

	def size
		@names.size
	end
	
	def apply_name_pair
		recursive_rename(@path_set)
	end

	def set_name_pair(&block)
		@path_set = []
		@names.each do |oldname|
			newname = block.call(oldname)
			@path_set.push([@DIR_NAME.join(oldname), @DIR_NAME.join(newname)])
		end
		return nil
	end

	def safe_rename(path_pairs)
		overlap = []
		path_pairs.each do |oldpath, newpath|
			if (!File.exists?(newpath))
				File.rename(oldpath, newpath)
			elsif (oldpath != newpath)
				overlap.push([oldpath, newpath])
			end
		end

		return overlap
	end

	def recursive_rename(path_pair)
		count   = path_pair.size
		overlap = self.safe_rename(path_pair) #renameして重複を得る

		if (overlap.size == 0)
			return true
		elsif (overlap.size <  count) #重複が減っていれば
			return self.recursive_rename(overlap)
		elsif (overlap.size == count)	#重複が一つも解決しなければ
			warn "Overlap: The following files did not rename, because already exists"
			overlap.each {|old, new| puts "#{old} => #{new}" }
			return false
		end
	end
end

class Countup
	def initialize(opt_arg, path_num)
		opt_arg = "0" if opt_arg.nil?
		@count  = opt_arg.integer
		@digit  = opt_arg.size
		@digit  = Math.log10(path_num+@count).ceil if max-@count < path_num
		alias :call :str
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
			@word_generator = Countup.new(rename_opt[:arg], path_num)
		else
			fail OptionFormatError, "#{rename_opt} isn't mode"
		end
	end

	def str
		@word_generator.call
	end
end
