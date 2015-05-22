require 'optparse'

class RenameRoutineError  < StandardError; end      #code bug
class RenameStandardError < RenameRoutineError; end #この例外を補足する

ERROR_MESSAGE = {
  enough:  "Not enough arguments",
  many:    "Too many arguments",
  onlyone: "can be specified rename-option is only one"
}

HELP_MESSAGE = {
  replace: "replace before to after. The after's defult value is empty string",
}

def error(message, num)
  warn "error: #{message}"
  exit(num)
end

def goodbye(message)
  puts message
  exit(0)
end

#you can use regexp ^,$,?,* in before-string
#エスケープしたくない文字もある
def simple_escape!(str)
  str.gsub!('(', '\(')
  str.gsub!(')', '\)')
  str.gsub!('[', '\[')
  str.gsub!(']', '\]')
  str.gsub!('{', '\{')
  str.gsub!('}', '\}')
  str.gsub!('+', '\+')
  str.gsub!('.', '\.')
  str.gsub!('?', '.')
  str.gsub!('*', '.*?')
  return str
end

def simple_escape(str)
  simple_escape!(str.dup)
end

def argv_parse
  ARGV[0] = '--help' if ARGV.size == 0
  opt = { dire: nil, before: nil, after: nil }

  parser = OptionParser.new
  parser.banner = 'Usage: rename [directory] [target-string] [-ren]'
  parser.on('-r before [after]',   HELP_MESSAGE[:replace]) do |before, after|
    opt[:before] = before
    opt[:after]  = after || ''
  end
  parser.parse!(ARGV)

  opt[:dire] = ARGV[0] || './'
  return opt

  rescue OptionParser::MissingArgument, OptionParser::InvalidOption=> ex
    error(ex.message, 10)
end
