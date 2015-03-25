#!/usr/bin/ruby
require 'minitest'
require 'minitest/autorun'
Dir.chdir("../")
require './simple-replace.rb'

class String
	def word
		self
	end
end

# "*"を使用しない置き換え, ^$?を使用
class Test_simple_replace < MiniTest::Test
	def test_simple_one_replace1
		assert_equal(simple_replace!("WDC000.jpg",   "DC" , "QQ"), "WQQ000.jpg")
	end

	def test_simple_one_replace2
		assert_equal(simple_replace!("WDC000.jpg",   "HH" , "QQ"), "WDC000.jpg")
	end
	
	def test_simple_some_replace1
		assert_equal(simple_replace!("ABC0ABC1.jpg", "ABC", "@@@"), "@@@0@@@1.jpg")
	end

	def test_simple_some_replace2
		assert_equal(simple_replace!("ABC0ABC1.jpg", "CBA", "@@@"), "ABC0ABC1.jpg")
	end
	
	def test_front_replace1
		assert_equal(simple_replace!("ABC0ABC1.jpg", "^ABC", "@@@"),"@@@0ABC1.jpg")
	end

	def test_front_replace2
		assert_equal(simple_replace!("aABC0ABC1.jpg", "^ABC", "@@@"), "aABC0ABC1.jpg")
	end

	def test_back_replace1
		assert_equal(simple_replace!(".jpg.jpg", ".jpg$", ".png"), ".jpg.png")
	end

	def test_back_replace2
		assert_equal(simple_replace!(".jpg.jpg2", ".jpg$", ".png"), ".jpg.jpg2")
	end

	def test_only_replace1
		assert_equal(simple_replace!("abc.jpg", "^abc.jpg", "ABC.png"), "ABC.png")
	end

	def test_only_replace2
		assert_equal(simple_replace!("0abc.jpg1", "^abc.jpg", "ABC.png"), "0abc.jpg1")
	end
	
	def test_one_question
		assert_equal(simple_replace!("WDC000.jpg", "W?C", "GGG"), "GGG000.jpg")
	end

	def test_some_question
		assert_equal(simple_replace!("ABCDEF.jpg", "B??E", "2222"), "A2222F.jpg")
	end

	def test_question_multi_point
		assert_equal(simple_replace!("AGBAUBATB.jpg", "A?B", "A9B"), "A9BA9BA9B.jpg")
	end

	#文字列の末尾にAが来た時にはA!にならない
	def test_question_multi_last
		assert_equal(simple_replace!("ABABA", "A?", "A!"), "A!A!A")
	end

	def test_some_question_multi
		assert_equal(simple_replace!("A1CA23CA456CA78CA90", "A??C", "@"), "A1C@A456C@A90")
	end
end

