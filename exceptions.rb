#OptionParser::InvalidOptionを継承させたほうがいいかも
class OptionFormatError < StandardError
	def initialize(mess = "invalid argument")
		super(mess)
	end
end

class RenameRoutineError  < StandardError; end      #code bug
class RenameStandardError < RenameRoutineError; end #この例外を補足する

