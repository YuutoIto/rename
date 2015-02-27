#!/usr/bin/ruby
require 'minitest'
require 'minitest/autorun'

Dir.chdir("../")
require './argv-parser.rb'

class Test_ARGVParser < MiniTest::Test
	#replace rename's true arguments
	def test_r0
		parser = ARGVParser.new ["/home/", "target", "-r", "after"]
		parser.parse_rename_option
		parser.parse_dir_targ

		assert_empty(parser.argv)
		assert_equal({:mode =>:replace, :arg=>"after"}, parser.rename_option)
		assert_equal("/home/", parser.directory)
		assert_equal("target", parser.target) 
		assert_empty(parser.other_option)
	end

	#引数の順序は塊で前後する場合が有る(実際はだめ)
	def test_r1
		parser = ARGVParser.new ["-r", "after", "/home/", "target"]
		parser.parse_rename_option
		parser.parse_dir_targ

		assert_empty(parser.argv)
		assert_equal({:mode=>:replace, :arg=>"after"}, parser.rename_option)
		assert_equal("/home/", parser.directory)
		assert_equal("target", parser.target) 
		assert_empty(parser.other_option)
	end

	#erase rename's true arguments
	def test_e1
		parser = ARGVParser.new ["/home/", "target", "-e"]
		parser.parse_rename_option
		parser.parse_dir_targ
		
		assert_empty(parser.argv)
		assert_equal({:mode=>:erase, :arg=>""}, parser.rename_option)
		assert_equal("/home/", parser.directory)
		assert_equal("target", parser.target) 
		assert_empty(parser.other_option)
	end
	
	#num countup rename's true arguments
	def test_n1
		parser = ARGVParser.new ["/home/", "target", "-n"]
		parser.parse_rename_option
		parser.parse_dir_targ
		
		assert_empty(parser.argv)
		assert_equal({:mode=>:number, :arg=>nil}, parser.rename_option)
		assert_equal("/home/", parser.directory)
		assert_equal("target", parser.target) 
		assert_empty(parser.other_option)
	end
	
	#num countup rename's true arguments
	def test_n2
		parser = ARGVParser.new ["/home/", "target", "-n", "00001"]
		parser.parse_rename_option
		parser.parse_dir_targ

		assert_empty(parser.argv)
		assert_equal({:mode=>:number, :arg=>"00001"}, parser.rename_option)
		assert_equal("/home/", parser.directory)
		assert_equal("target", parser.target) 
		assert_empty(parser.other_option)
	end

	#########MISS CASE##########
	#-r STR のSTR部分がない
	def test_miss1
		parser = ARGVParser.new ["/home/", "target", "-r"] 
		assert_raises(OptionFormatError){ parser.parse_rename_option }
	end

	#置き換え対象がない target
	def test_miss2
		parser = ARGVParser.new ["/home/", "-r", "after"]
		parser.parse_rename_option
		assert_raises(OptionFormatError){ parser.parse_dir_targ }
	end

	#rename-optionが複数ある
	def test_miss3
		parser = ARGVParser.new ["/home/","target",  "-r", "after", "-e"]
		assert_raises(OptionFormatError){ parser.parse_rename_option }
	end

	#余分なオプション(引数)がある
	def test_miss4
		parser = ARGVParser.new ["/home/","target", "Myinvalid", "-r" ,"after"]
		parser.parse_rename_option
		assert_raises(OptionFormatError){ parser.parse_dir_targ }
	end
end

