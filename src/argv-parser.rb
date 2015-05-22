require 'optparse'
require './utils'

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
