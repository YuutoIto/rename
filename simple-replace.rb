#replase target. you can use regexp ^,$,?,*
#メタ文字の効果が一般的なものとは一部違う

#This program
# ^ matches the only front of string 先頭にある時のみメタ文字
# & matches the only back of string 末尾にある時のみメタ文字
# ? 内部で正規表現を使用するときに、任意の一文字に置き換わる
# * target中の* に一致したfilenameの文字列を変更対象にする

#-e オプションとかで拡張子を対象外にするときはsimple_replaceの呼び出し側でや
#filenameからtargetに一致する部分をブロックの戻り値に置き換える
#ブロックに変数は渡さない

#このメソッドを使う前に引数の整合性などはチェックする

=begin
"ABC", "*ABC", { @ } は"@ABC"になる
"ABC", "ABC*", { @ } は"ABC@"になる

gsubの第二引数にブロックを渡すと、ブロックが一度だけ実行されるけれど
gsubの第二引数を使用せずにブロックを使用すると毎回引数のブロックが実行される
=end

#例外使う為
require './rename-core.rb'

def simple_replace_aste!(filename, target, after_str)
	fail RenameRoutineError,'"*" not found' unless target.count("*") == 1

	pivod = target.delete("*")

	if target[0] == "*"
		filename.gsub!(/.*?(#{pivod})/, after_str + '\1')
	elsif target[-1] == "*"
		pivod.sub!(/^\^/, "$") #先頭が^なら$に置き換える
		pivod.gsub!("\\.", ".\\")

		filename.reverse!
		filename.gsub!(/.*?(#{pivod.reverse})/, after_str.reverse + '\1')
		filename.reverse!
	else #between
		front, back = target.split("*")

		#$のみが使用されていた場合は反転して処理
		if front[0] != "^" && back[-1] == "$" 
			back[-1] = "^" #下準備
			front.gsub!("\\.", ".\\")
			back.gsub!("\\.", ".\\")

			front, back = back.reverse, front.reverse

			filename.reverse!
			filename.gsub!(/(#{front}).*?(#{back})/, '\1' + after_str.reverse + '\2')
			filename.reverse!
		else#通常のbetween処理
			filename.gsub!(/(#{front}).*?(#{back})/, '\1' + after_str + '\2')
		end
	end

	return filename
end

#filenameは改変される、戻り値も改変後の値を返す
def simple_replace!(filename, target, after_str)
	target.gsub!(".", "\\.")
	target.gsub!("?", ".")

	case target.count("*")
	when 0
		filename.gsub!(/#{target}/, after_str)
	when 1
		simple_replace_aste!(filename, target, after_str)
	else
	 fail RenameStandardError, 'target can use "*" is only one'
	end

	return filename
end

#easy: non-break
def simple_replace(filename, target, after_str)
	simple_replace!(filename.dup, target.dup, after_str.dup)
end

#require './~test-simple-replace-aste'
#require './~test-simple-replace-non-aste'
