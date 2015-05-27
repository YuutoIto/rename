require 'optparse'
require 'find'

module RenameUtils
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

  class String
    def join(path)
      File.join(self, path)
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

  #you can use regexp ^,$,?,* in before-string # {{{
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
  # }}}

  # Parse directly ARGV
  def argv_parse# {{{
    ARGV[0] = '--help' if ARGV.size == 0
    opt = { dir: './', before: nil, after: '', type: :file } #default values

    parser = OptionParser.new
    parser.banner = 'Usage: rbrn' #TODO
    parser.on('-r BEFORE [AFTER]',   HELP_MESSAGE[:replace]) do |before|
      opt[:before] = before
      opt[:after]  = ARGV.shift if ARGV[0][0] != '-'
    end

    parser.on('-t TYPE', HELP_MESSAGE[:type]) do |type|
      if /^(file|dir|all)$/ =~ type
        opt[:type] = type.to_sym
      else
        error(ERROR_MESSAGE[:type], 12)
      end
    end
    parser.parse!(ARGV)

    opt[:dir] = ARGV[0] if ARGV[0]
    return opt

  rescue OptionParser::MissingArgument, OptionParser::InvalidOption=> ex
    error(ex.message, 13)
  end# }}}

  def get_pathes(opt)# {{{
    error("#{opt[:dir]} is not exists.", 30) unless Dir.exists?(opt[:dir])

    pathes = Dir.glob(opt[:dir].join("*"))
    case opt[:type]
    when :file
      pathes.select!{ |path| File.file?(path) }
    when :dir
      pathes.select!{ |path| File.directory?(path) }
    end
    goodbye('') if pathes.empty?

    return pathes.sort_by! { |path| File.basename(path) }
  end# }}}

  def get_before_after(opt, pathes)# {{{
    regexp = Regexp.new(simple_escape(opt[:before]))

    pathes.map do |path|
      before_name = File.basename(path)
      after_name  = before_name.gsub(regexp, opt[:after])
      puts "%-32s  =>  %s" % [before_name, after_name]

      [path, opt[:dir].join(after_name)]
    end

    return pathes.delete_if {|old, new| old == new }
  end# }}}

  #if elements is not deleted return nil.
  def safe_rename_pairs!(path_pairs)
    return path_pairs.reject! do |old, new|
      next !File.exists?(new) && File.rename(old, new)
    end
  end

  # safe_rename_pairs!を名前が変更しきれなくなるまで繰り返す
  def recursive_rename!(path_pairs)
    unless safe_rename_pairs!(path_pairs)
      warn "Overlap: The following files did not rename, because already exists"
      overlap.each {|old, new| puts "#{old} => #{new}" }
      return false
    end

    return path_pairs.size == 0 || recursive_rename!(path_pairs)
  end
end
