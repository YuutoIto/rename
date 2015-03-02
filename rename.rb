require "./rename-core"
require "./simple-replace"
require "./argv-parser"

=begin
常に最新の状態で使用できるようにリポジトリのrename.rbを呼び出す
rubyのコードを書く&添付する

新しくオプションの追加するときにはdir,targをパースする前に抜き出す
エスケープが必要な記号を用いたテストがない
スペースを繰り返す時はエスケープが必要かも
-n　を使った時文字列がマッチしなかった場合にもカウントアップされちゃう
		gsubで複数マッチした時に同じファイルでは同じ数値を使用するように呼び出し時にstrを使用しているけれど
		それをやめて@newwordオブジェクトを渡してgusbのブロックで実行させれば空読みがなくなるはず
		match->block.call->gsub("", str)でもいいけどmatchで処理食うな

1.jpg 2.jpg 10.jpg とあったとすると 1.jpg 10.jpg 2.jpgの順になる
		-nを指定した時は　文字でソートするのではなく数値でソードできるようにする

rubyの正規表現を生で使うモードを作る
		--free --super とか?

変更チェックの出力桁数を指定する　オプションを作る
=end

class Renamer < ARGVParser
	def initialize(argv)
		super(argv)
	end

	def parse
		self.all_parse
		@pathes  = TargetPathes.new(self.directory, :file)
		@newword = NewWord.new(self.rename_option, @pathes.size)
	end

	def rename
		@pathes.set_name_pair do |oldname|
			newname = simple_replace(oldname, self.target, @newword)
			newname = oldname if newname.empty?

			oldname = sprintf("%-32s", oldname) #インデントを揃える
			puts "#{oldname}  =>  #{newname}"
			next newname
		end

		puts "Rename these? (y/N)"
		case STDIN.gets.chomp
		when /Y/i, /YES/i
			@pathes.apply_name_pair
		end
	end
end

##renamer entry point
r = Renamer.new(ARGV)
r.parse
r.rename
