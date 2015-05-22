require 'optparse'

class RenameRoutineError  < StandardError; end      #code bug
class RenameStandardError < RenameRoutineError; end #この例外を補足する

ERROR_MESSAGE = {
  enough:  'Not enough arguments.',
  many:    'Too many arguments.',
  onlyone: 'Can be specified rename-option is only one.',
  type: 'Invalid type, You can use file, dir and all. The default is file.',
}

HELP_MESSAGE = {
  replace: 'replace before to after. The default value of after is empty string.',
  type: 'The kind of the targets. You ca use file, dir and all.',
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
  opt = { dir: './', before: nil, after: '', type: :file } #default values

  parser = OptionParser.new
  parser.banner = 'Usage: rbrn' #TODO
  parser.on('-r BEFORE [AFTER]',   HELP_MESSAGE[:replace]) do |before, after|
    opt[:before] = before
    opt[:after]  = after if after
  end
  parser.parse!(ARGV)

  opt[:dir] = ARGV[0] if ARGV[0]
  return opt

  rescue OptionParser::MissingArgument, OptionParser::InvalidOption=> ex
    error(ex.message, 13)
end
