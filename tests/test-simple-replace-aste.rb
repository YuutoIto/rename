#!/usr/bin/ruby
require 'minitest'
require 'minitest/autorun'
require '../simple-replace.rb'

class Test_simple_replace_front < MiniTest::Test
	def test_simple
		assert_equal(simple_replace!("242ABC872246ABC", "*ABC" , "-"), "-ABC-ABC")
	end

	def test_simple_notmatch
		assert_equal(simple_replace!("242ABC872246ABC", "*ABC" , "-"), "-ABC-ABC")
	end
	
	def test_backonly
		assert_equal(simple_replace!("123ABC987654ABC", "*ABC$", "-"), "-ABC")
	end

	def test_backonly_notmatch
		assert_equal(simple_replace!("123ABC987654ABC.jpg", "*ABC$", "-"), "123ABC987654ABC.jpg")
	end

	def test_1
		assert_equal(simple_replace!("WCM000.jpg", "*CM000.jpg", "888"), "888CM000.jpg")
	end

	def test_2
		assert_equal(simple_replace!("WCM000.jpg", "*CM", "888"), "888CM000.jpg")
	end
	
	#rep_tarの先頭(splitの戻り値[0])に""が入る
	def test_3
    assert_equal(simple_replace!("ABC00ABC11ABC.png", "*ABC", "@"), "@ABC@ABC@ABC.png")
	end
end

class Test_simple_replace_back < MiniTest::Test
	#^なしで先頭からマッチする
	def test_simple1
		assert_equal(simple_replace!("WCM000.jpg", "WC*", "99999"), "WC99999")
	end

	#test_back_simple1の ^ 使用版
	def test_frontonly1
		assert_equal(simple_replace!("WCM000.jpg", "^WC*", "99999"), "WC99999")
	end

	def test_frontonly2
		assert_equal(simple_replace!("ABC987ABC", "^ABC*", "@"), "ABC@")
	end

	def test_simple2ddd
		assert_equal(simple_replace!("WCM000.jpg", "C*" , "99999"), "WC99999")
	end

	def test_simple3
		assert_equal(simple_replace!("ABCABDABM.png", "AB*", "@"), "AB@AB@AB@")
	end

	def test_backempty
		assert_equal(simple_replace!("CD00CD", "CD*", "@"), "CD@CD@")
	end

	def test_frontonly_notmatch
		assert_equal(simple_replace!("oABC987ABC", "^ABC*", "@"), "oABC987ABC")
	end
end

class Test_simple_replace_between < MiniTest::Test
	def test_simple1
		assert_equal(simple_replace!("WDC000.jpg", "WDC*.jpg", "1111"), "WDC1111.jpg")
	end

	def test_simple2
		assert_equal(simple_replace!("A00BA00B", "A*B", "11"), "A11BA11B")
	end

	def test_front
		assert_equal(simple_replace!("A00BA00B", "^A*B", "11"), "A11BA00B")
	end

	#反転処理が必要なパターン
	def test_back
		assert_equal(simple_replace!("A00BA00B", "A*B$", "11"), "A00BA11B")
	end

	def test_front_and_back
		assert_equal(simple_replace!("A00BA00B", "^A*B$", "11"), "A11B")
	end
end


class Test_simple_replace_aste_question < MiniTest::Test
	def test_1
		assert_equal(simple_replace!("A1ooBA2klmB", "A?*B", "@"), "A1@BA2@B")
	end

	def test_2
		assert_equal(simple_replace!("A1ooBA2lkmB", "A*?B", "@"), "A@oBA@mB")
	end

	def test_3
		assert_equal(simple_replace!("A1BgggA2B", "A?B*A?B", "@"), "A1B@A2B")
	end

	def test_4
		assert_equal(simple_replace!("A1BA2B", "A?B*A?B", "@"), "A1B@A2B")
	end

	def test_5
		assert_equal(simple_replace!("ABC123.jpg", "???*.jpg", "999"), "ABC999.jpg")
	end

	#面白い使い方
	def test_6
		assert_equal(simple_replace!("ABCD", "*?", "@"), "@A@B@C@D")
	end

	#面白い使い方
	def test_7
		assert_equal(simple_replace!("1234", "?*", "@"), "1@2@3@4@")
	end

	#$を使用しないと全ての文字の前に@がつく
	def test_8
		assert_equal(simple_replace!("ABC123D", "*?$", "@"), "@D")
	end

	def test_front_back
		assert_equal(simple_replace!("ABC123.jpg", "^???*.jpg$", "999"), "ABC999.jpg")
	end

	def test_non_replace1
		assert_equal(simple_replace!("ooABC123.jpg", "^ABC*.jpg$", "999"), "ooABC123.jpg")
	end

	def test_non_replace2
		assert_equal(simple_replace!("ABC123.jpgoo", "^???*.jpg$", "999"), "ABC123.jpgoo")
	end
end


