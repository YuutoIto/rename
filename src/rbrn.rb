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

class OptionParser
  attr_accessor :dest_hash
  attr_accessor :message_list

  def to_hash(key, *args, &block)
    block = lambda{|v| dest_hash[key] = v} unless block_given?
    on(*args, *message_list[key], block)
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
  banner: "Usage: #{File.basename($0)} <mode [args...]> [-t type] [-d dir] [-s select] [-j reject]",
  replace: ["Replace /BEFORE/ to 'AFTER' with String#gsub.",
            "If 'AFTER' is empty, remove /BEFORE/.",
            "You can use special regexps in /BEFORE/."],
  type: 'Set rename target type. (all)',
  dir: 'Replace target directory. (./)',
  select: 'Select file and directory with regexp. (//)',
  reject: 'Reject file and directory with regexp. (//)',
  raw: 'Match without regexp',
  special_regexp: ["%b\t All strings in () [] {}",
                   "%B\t Any one of () [] {}"],
}

ORIGIANL_REGEXP = {
  '%b' => '\s*(\(.*?\)|\[.*?\]|\{.*?\})\s*', # strings in all blocks
  '%B' => '[(){}\[\]]', # any block
  '%N' => '^\d+(\.|\s*-)?\s*'
}

module RenameUtils
  class RenameRoutineError  < StandardError; end      #code bug
  class RenameStandardError < RenameRoutineError; end #catch this exception

  def get_regexp(str, raw = nil)
    regex_str = str.dup
    regex_str = Regexp.escape(regex_str) if raw
    ORIGIANL_REGEXP.each {|k,v| regex_str.gsub!(k, v) }
    return Regexp.new(regex_str)
  end

  def parse_argv(arguments)
    argv = arguments.dup
    opt = { mode: nil, before: nil, after: '', type: :all, dir: './', yes: false } #default values
    parser = OptionParser.new
    parser.message_list = HELP_MESSAGE
    parser.dest_hash = opt
    parser.banner = HELP_MESSAGE[:banner]

    parser.separator ['', 'Mode options']
    parser.to_hash(:replace, '-r BEFORE [AFTER]'){|before| opt.update(mode: :replace, before: before)}

    parser.separator ['', 'Other options']
    parser.to_hash(:type, '-t file|dir|all', [:file, :dir, :all])
    parser.to_hash(:dir, '-d DIR')
    parser.to_hash(:select, '-s REGEXP', Regexp)
    parser.to_hash(:reject, '-j REGEXP', Regexp)
    parser.to_hash(:raw, '-R', '--raw', TrueClass)
    parser.to_hash(:yes, '-y', '--yes', TrueClass)

    parser.separator ['', 'Special regexp']
    parser.on_tail(*(HELP_MESSAGE[:special_regexp].map{|s| parser.summary_indent+s}))

    parser.parse!(argv)

    # get after string of the replace mode
    if opt[:mode] == :replace && !argv.empty?
      opt[:after] = argv.shift
    end

    opt[:mode] = :show if opt[:mode].nil? && opt.in?(:select, :reject)
    return opt
  rescue OptionParser::MissingArgument, OptionParser::InvalidOption=> ex
    error(ex.message, 13)
  end

  def get_pathes(opt)
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
  end

  def get_before_after(opt, pathes)
    regexp = get_regexp(opt[:before], opt[:raw])

    path_pairs = pathes.map do |path|
      before_name = File.basename(path)
      after_name  = before_name.gsub(regexp, opt[:after])
      next nil if before_name == after_name

      puts "%-34s => '%s'" % ["'#{before_name}'", after_name]
      next [path, opt[:dir].join(after_name)]
    end

    return path_pairs.compact
  end

  #if elements is not deleted return nil.
  def safe_rename_pairs!(path_pairs)
    return path_pairs.reject! do |old, new|
      next !File.exist?(new) && File.rename(old, new)
    end
  end

  #execute safe_rename_pairs! while can rename.
  def recursive_rename!(path_pairs)
    return true if path_pairs.empty?

    unless safe_rename_pairs!(path_pairs)
      warn "Overlap: The following files did not rename, because already exist"
      path_pairs.each {|old, new| puts "#{old} => #{new}" }
      return false
    end

    return recursive_rename!(path_pairs)
  end
end

return unless __FILE__ == $0

#main routine
Version = 2.4
include RenameUtils
$VERBOSE = (ENV['DEBUG'].to_i != 0)? true : nil

#preprocessing to parse arguments.
ARGV[0] = '--help' if ARGV.empty?

opt = parse_argv(ARGV)
warn opt&.inspect
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
  if opt[:yes] ||  /^(Y|YES)$/i =~ STDIN.gets.to_s.chomp
    recursive_rename!(bf_pairs)
  end
end
