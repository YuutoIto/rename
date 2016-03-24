ruby製リネーマー  
リネーム実行前にリネーム前後のファイル名を出力し、確認プロンプト表示します。  
リネーム中にファイル名が重複がした場合は、先に他のリネームを実行し、終了後に再度変更を試みます。  
rubyの正規表現がそのまま使用可能です('()'や'\1'の使用も可能)。  


#使い方

```text
rbrn <mode [args..]> [-t type] [-d dir]  
    <mode>                 現在は -r のみ指定可能
    -r BEFORE [AFTER]      BEFOREをAFTERに変更する、AFTERを省略した場合は削除
    -t TYPE                対象となるファイルの種類を選択(file,dir,all) デフォルトは all
    -d DIR                 対象となるディレクトリを指定 デフォルトは ./
    -h --help              ヘルプを表示
```
    
#使用例

```shell
$ ls target_dir
WCW000.jpg WCW001.jpg WCW002.jpg

$ rbrn -r WCW ACA  
'WCW000.jpg' => 'ACA000.jpg'
'WCW001.jpg' => 'ACA001.jpg'
'WCW002.jpg' => 'ACA002.jpg'

3 names rename
Rename these? (y/N) y

$ ls target_dir
ACA000.jpg ACA001.jpg ACA002.jpg
```

#今後
* ファイル名に連番を使用できるようにする
* 対象とする文字列にvim風のテキストオブジェクトを使えるようにする
* 変更点などをカラー表示して見やすくする


