=begin
replase target. you can use regexp ^,$,?,*
メタ文字の効果が一般的なものとは一部違う

This program
 ^ matches the only front of string 先頭にある時のみメタ文字
 & matches the only back of string 末尾にある時のみメタ文字
 ? 内部で正規表現を使用するときに、任意の一文字に置き換わる
 * target中の* に0文字以上一致したfilenameの文字列を変更対象にする
=end


#simple_replace専用の関数
#エスケープしたくない文字もある
class String
	def simple_escape
		newstr = self.dup
		newstr.gsub!("(", "\\(")
		newstr.gsub!(")", "\\)")
		newstr.gsub!("[", "\\[")
		newstr.gsub!("]", "\\]")
		newstr.gsub!("{", "\\{")
		newstr.gsub!("}", "\\}")
		newstr.gsub!("+", "\\+")
		newstr.gsub!(".", "\\.")
		newstr.gsub!("?", ".")
		newstr.delete!('*')
		return newstr
	end

	def simple_escape!
		self.gsub!("(", "\\(")
		self.gsub!(")", "\\)")
		self.gsub!("[", "\\[")
		self.gsub!("]", "\\]")
		self.gsub!("{", "\\{")
		self.gsub!("}", "\\}")
		self.gsub!("+", "\\+")
		self.gsub!(".", "\\.")
		self.gsub!("?", ".")
		self.delete!('*')
	end
end

#filenameは改変される、戻り値も改変後の値を返す
def simple_replace!(filename, target, after_str)
	case target.count("*")
	when 0
		target.simple_escape! #ここでエスケープ
		filename.gsub!(/#{target}/, after_str.word)            #通常置き換え
	when 1
		simple_replace_aste!(filename, target, after_str) #*マッチ置き換え
	else
	 fail RenameStandardError, 'target can use "*" is only one'
	end

	return filename
end

def simple_replace(filename, target, after_str)
	simple_replace!(filename.dup, target.dup, after_str)
end

def simple_replace_aste!(filename, target, after_str)
	if target[0] == "*" || target[/^../] == "^*"
		target.simple_escape!
		filename.gsub!(/.*?(#{target})/, after_str.word + '\1')

	elsif target[-1] == "*" || target[/..$/] == "*$"
		target.sub!(/^\^/, "$") #先頭が^なら$に置き換える
		filename.reverse!
		target.simple_escape!  #reverse!したあとにespace

		filename.gsub!(/.*?(#{target.reverse})/, after_str.word.reverse + '\1')
		filename.reverse!

	else #between
		front, back = target.split("*")

		#if "$" other than unused, reverse strings
		if back[-1] == "$" && front[0] != "^" 
			back[-1] = "^"

			# 反転、エスケープして交換
			front.reverse!.simple_escape!
			back.reverse!.simple_escape!
			front, back = back, front

			filename.reverse!
			filename.gsub!(/(#{front}).*?(#{back})/, '\1' + after_str.word.reverse + '\2')
			filename.reverse!

		else#通常のbetween処理
			front.simple_escape!
			back.simple_escape!
			filename.gsub!(/(#{front}).*?(#{back})/, '\1' + after_str.word + '\2')
		end
	end

	return filename
end

#require './~test-simple-replace-aste'
#require './~test-simple-replace-non-aste'
