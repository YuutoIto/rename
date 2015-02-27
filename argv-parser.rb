require 'optparse'

#OptionParser::InvalidOptionを継承させたほうがいいかも
class OptionFormatError < StandardError
	def initialize(mess = "invalid argument")
		super(mess)
	end
end


class ARGVParser
	@@ERROR_MESSAGE = {
		enough:  "Not enough arguments",
		many:    "Too many arguments",
  	onlyone: "can be specified rename-option is only one"
	}
	
	@@HELP_MESSAGE = {
		replace: "replace target-string to STR",
		erase:   "erase target-string",
		number:  "replace target-string to countup number"
	}

	attr_reader :argv
	attr_reader :rename_option
	attr_reader :other_option
	attr_reader :directory
	attr_reader :target

	def initialize(argv)
		@argv = (argv.empty?)? ["-h"]: argv
		@rename_option = Hash.new
		@other_option  = Array.new
		@directory     = String.new
		@target        = String.new
	end

	def debug_variable
		puts "argv #{@argv}"
		puts "rename_option #{@rename_option}"
		puts "other_option  #{@other_option}"
		puts "directory #{@directory}"
		puts "target #{@target}"
	end

	#can access instance-variable using [:hash]
	def [](symb)
		self.send(symb)
	end

	#-y Yes/Noを尋ねないで実行
	#-b バックアップを取る?
	#-s 出力フォーマット指定

	#This function returns a rename-option, and it's argument
	#オプションの整合性判定はしない
	def parse_rename_option
		def @rename_option.set!(rename_mode, opt_arg)
			fail OptionFormatError, @@ERROR_MESSAGE[:onlyone] unless self.empty?
			
			self[:mode] = rename_mode
			self[:arg]  = opt_arg
		end

		parser = OptionParser.new(nil, 10)
		parser.banner = 'Usage: rename [directory] [target-string] [-ren]'
		parser.on('-r STR',   @@HELP_MESSAGE[:replace]){|opt| @rename_option.set!(:replace, opt) }
		parser.on('-e',       @@HELP_MESSAGE[:erase])  {      @rename_option.set!(:erase,    "") }
		parser.on('-n [NUM]', @@HELP_MESSAGE[:number]) {|opt| @rename_option.set!(:number,  opt) }

		#set!からもメッセージが上がってくる
		begin
			parser.parse!(@argv)
		rescue OptionFormatError => ex
			raise OptionFormatError, ex.message
		rescue OptionParser::MissingArgument => ex
			raise OptionFormatError, ex.message
		rescue OptionParser::InvalidOption=> ex
			raise OptionFormatError, ex.message
		end

		#特異メソッドを消す
		class << @rename_option; remove_method :set! end

		return @rename_option
	end

	def parse_dir_targ
		if @argv.size <= 1
			fail OptionFormatError, @@ERROR_MESSAGE[:enough]
		elsif 3 <= @argv.size
			raise OptionFormatError, @@ERROR_MESSAGE[:many]
		end

		#要素を空にする必要がある
	  @directory, @target = @argv.slice!(0,2)
	end

	#全てのパースと例外処理をやってくれる
	def all_parse
		begin
			parse_rename_option
			parse_dir_targ
			return self
		rescue OptionFormatError  => ex
			warn "error: #{ex.message}"
			exit 1
		end
	end
end#Parser
