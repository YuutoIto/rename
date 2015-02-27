#!/usr/bin/env ruby

rn_except		= File.read("../exceptions.rb")
rn_parser		= File.read("../argv-parser.rb").sub("require './exceptions.rb'", "")
rn_replace	= File.read("../simple-replace.rb").sub("require './exceptions.rb'", "")
rn_core			= File.read("../rename-core.rb").sub("require './exceptions.rb'", "")
rn_main			= File.read("../rename.rb").gsub(/require \".*?\"/, "")

warn "except load error" if rn_except.nil?
warn "parser load error" if rn_parser.nil?
warn "replace load error" if rn_replace.nil?
warn "core load error" if rn_core.nil?
warn "main load error" if rn_main.nil?

def comment_delete!(file)
	file.gsub!(/^=begin.*?^=end/m, "")
end

comment_delete!(rn_main)

File.open("rbrn", "w") do |file|
	file.write("#!/usr/bin/env ruby\n\n")
	file.write(rn_except)
	file.write("\n")
	file.write(rn_parser)
	file.write("\n")
	file.write(rn_replace)
	file.write("\n")
	file.write(rn_core)
	file.write("\n")
	file.write(rn_main)
end

