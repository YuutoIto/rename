=begin USEGE
opt = Parsers.new(ARGV)
opt.all_parse
#success return self
#filed   exit

other-optionsが未完成
=end

=begin
rename directory target [options] rename-option [option's arguments]
rename-options
	-r STR replace the target to <str>
	-e [NUM] erase the target
	-n [NUM] 連続する数字に置き換える
	-h,--help
=end

#ARGVから渡されるオプションは全て文字列
#-h --help --versionはデフォで実装されているようだ　＃だがこれを使わない使えない

#rename-methodはファイル名を引数にとって、変更後のファイル名を返す。
#rename-method file-name argment#
#引数の順序が自由なのは正常に動作するが、各オプションの省略できる引数を省略した場合、ユーザーが意図しない動作を起こす
#よって順序はrename dir targ options option-argument の順を強制する
#しかし処理の手順にしてはこの順序を考慮しないほうが楽なので現在の処理手順を継続する

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
		replace: "replace target to STR",
		erase:   "erase target",
		number:  "replace target to number"
	}

	def initialize(argv)
		@argv = argv
		@rename_option = {}
		@other_option  = []
		@directory     = ""
		@target        = ""
	end
	
	attr_reader :argv
	attr_reader :rename_option
	attr_reader :other_option
	attr_reader :directory
	attr_reader :target

	#can access instance-variable using [:hash]
	def [](symb)
		self.send(symb)
	end

	#This function returns a rename-option, and it's argument
	#argvからrename-optionが取り抜かれる
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

	#-y Yes/Noを尋ねないで実行
	#-b バックアップを取る?
	#-h ヘルプを処理する
	def parse_other_option
		# parser = OptionParser.new
		# parser.on('-y')
		# parser.on('-h', '--help')
	end

	#Filed, when argv has the rest
	def parse_dir_targ
		if @argv.size < 2
			fail OptionFormatError, @@ERROR_MESSAGE[:enough]
		elsif 2 < @argv.size
			raise OptionFormatError, @@ERROR_MESSAGE[:many]
		end

	  @directory, @target = @argv.slice!(0,2)
	end

	#全てのパースと例外処理をやってくれる
	def all_parse
		begin
			parse_rename_option
			parse_other_option
			parse_dir_targ
			return self
		rescue OptionFormatError  => ex
			warn "error: #{ex.message}"
			exit 1
		end
	end
end#Parser
