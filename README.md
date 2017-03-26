#ruby製リネーマー  

##Features
* リネーム実行前に確認プロンプト表示
* ファイル名が重複した場合、1週した後に再実行
* Rubyの正規表現がそのまま使える('()'や'\1'で文字列の使い回し可能)
* 置換に独自の正規表現が使用可能(Special regexp)


##Usage

```text
Usage: rbrn <mode [args...]> [-t type] [-d dir] [-s select] [-j reject]

Mode options
    -r BEFORE [AFTER]                Replace /BEFORE/ to 'AFTER' with String#gsub.
                                     If 'AFTER' is empty, remove /BEFORE/.
                                     You can use special regexps in /BEFORE/.

Other options
    -t file|dir|all                  Set rename target type. (all)
    -d DIR                           Replace target directory. (./)
    -s REGEXP                        Select file and directory with regexp. (//)
    -j REGEXP                        Reject file and directory with regexp. (//)

Special regexp
    %b	 All strings in () [] {}
    %B	 Any one of () [] {}
```


##Example

```shell
$ ls target_dir
A0.jpg A1.jpg A2.jpg

$ rbrn -r A B
'A0.jpg' => 'B0.jpg'
'A1.jpg' => 'B1.jpg'
'A2.jpg' => 'B2.jpg'

3 names rename
Rename these? (y/N) y

$ ls target_dir
B0.jpg B1.jpg B2.jpg
```

##Todo
* ファイル名に連番を使用できるようにする
* 変更点などをカラー表示して見やすくする
* 設定ファイルから独自正規表現を読み込む
