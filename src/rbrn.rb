#!/usr/bin/env ruby
require 'optparse'
require 'find'

class String
  def join(path)
    File.join(self, path)
  end
end

class Hash
  def in?(*keys)
    keys.any?{|k| has_key?(k)}
  end
end

def error(message, num)
  warn "error: #{message}"
  exit(num)
end

def goodbye(message)
  puts message
  exit(0)
end

ERROR_MESSAGE = {
  enough:  'Not enough arguments.',
  many:    'Too many arguments.',
  onlyone: 'Can be specified rename-option is only one.',
  type: 'Invalid type, Choose from file, dir and all.',
}

HELP_MESSAGE = {
  replace: ["Replace /BEFORE/ to 'AFTER' with String#gsub.",
            "If 'AFTER' is not set, remove /BEFORE/.",
            "You can use special regexps"],
  type: 'Set rename target type. (all)',
  dir: 'Replace target directory. (./)',
  select: 'Select file and directory with regexp. (//)',
  reject: 'Reject file and directory with regexp. (//)',
  special_regexp: ["%b\t All strings in () [] {}",
                   "%B\t Any one of () [] {}"]
}

ORIGIANL_REGEXP = {
  '%b' => '\s*(\(.*?\)|\[.*?\]|\{.*?\})\s*', # all blocks
  '%B' => '[(){}\[\]]', # any block
}

module RenameUtils # {{{
  class RenameRoutineError  < StandardError; end      #code bug
  class RenameStandardError < RenameRoutineError; end #catch this exception

  def get_regexp(str) # {{{
    regex_str = str.dup
    ORIGIANL_REGEXP.each {|k,v| regex_str.gsub!(k, v) }
    return Regexp.new(regex_str)
  end # }}}

  def parse_argv(arguments) # {{{
    argv = arguments.dup
    opt = { mode: nil, before: nil, after: '', type: :all, dir: './', } #default values
    parser = OptionParser.new
    parser.banner = 'Usage: rbrn <mode [args..]> [-t type] [-d dir] [-s select] [-j reject]'

    parser.separator 'Mode options'
    parser.on('-r BEFORE [AFTER]', *HELP_MESSAGE[:replace]) do |before|
      opt[:mode] = :replace
      opt[:before] = before
    end

    parser.separator ''
    parser.separator 'Other options'

    parser.on('-t TYPE', [:file, :dir, :all], HELP_MESSAGE[:type]){|type| opt[:type] = type}
    parser.on('-d DIR', HELP_MESSAGE[:dir]){|dir| opt[:dir] = dir}
    parser.on('-s REGEXP', Regexp, HELP_MESSAGE[:select]){|select| opt[:select] = select}
    parser.on('-j REGEXP', Regexp, HELP_MESSAGE[:reject]){|reject| opt[:reject] = reject}

    parser.separator ''
    parser.separator 'Special regexp'
    parser.on_tail(*(HELP_MESSAGE[:special_regexp].map{|s| parser.summary_indent+s}))

    parser.parse!(argv)

    #get after string of the replace mode
    if opt[:mode] == :replace && !argv.empty?
      opt[:after] = argv.shift
    end

    opt[:mode] = :show if opt[:mode].nil? && opt.in?(:select, :reject)
    return opt
  rescue OptionParser::MissingArgument, OptionParser::InvalidOption=> ex
    error(ex.message, 13)
  end # }}}

  def get_pathes(opt) # {{{
    error("#{opt[:dir]} is not exist.", 30) unless Dir.exist?(opt[:dir])

    pathes = Dir.glob(opt[:dir].join("*"))
    case opt[:type]
    when :file
      pathes.select!{|path| File.file?(path) }
    when :dir
      pathes.select!{|path| File.directory?(path) }
    end
    pathes.select!{|path| opt[:select] =~ path} if opt[:select]
    pathes.reject!{|path| opt[:reject] =~ path} if opt[:reject]
    exit 0 if pathes.empty?

    return pathes.sort_by!{|path| File.basename(path) }
  end # }}}

  def get_before_after(opt, pathes) # {{{
    regexp = get_regexp(opt[:before])

    path_pairs = pathes.map do |path|
      before_name = File.basename(path)
      after_name  = before_name.gsub(regexp, opt[:after])
      next nil if before_name == after_name

      puts "%-34s => '%s'" % ["'#{before_name}'", after_name]
      next [path, opt[:dir].join(after_name)]
    end

    return path_pairs.compact
  end # }}}

  #if elements is not deleted return nil.
  def safe_rename_pairs!(path_pairs) # {{{
    return path_pairs.reject! do |old, new|
      next !File.exist?(new) && File.rename(old, new)
    end
  end # }}}

  #execute safe_rename_pairs! while can rename.
  def recursive_rename!(path_pairs) # {{{
    return true if path_pairs.empty?

    unless safe_rename_pairs!(path_pairs)
      warn "Overlap: The following files did not rename, because already exist"
      path_pairs.each {|old, new| puts "#{old} => #{new}" }
      return false
    end

    return recursive_rename!(path_pairs)
  end # }}}
end # }}}

return unless __FILE__ == $0

#main routine
Version = 2.3
include RenameUtils
$VERBOSE = (ENV['DEBUG'].to_i == 0)? nil : true

#preprocessing to parse arguments.
ARGV[0] = '--help' if ARGV.empty?

warn opt = parse_argv(ARGV)
pathes = get_pathes(opt)

case opt[:mode]
when :show
  pathes.each{|path| puts "'%s'" % File.basename(path)}
when :replace
  #show rename candidate and get it.
  bf_pairs = get_before_after(opt, pathes)
  puts "\nrename #{bf_pairs.size}/#{pathes.size}"

  exit if bf_pairs.size == 0

  print 'Rename these? (y/N) '
  if /^(Y|YES)$/i =~ STDIN.gets.to_s.chomp
    recursive_rename!(bf_pairs)
  end
end
