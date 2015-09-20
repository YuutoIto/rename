ruby製リネーマー  
リネーム実行前にリネーム前後のファイル名を出力し、確認プロンプト表示します。  
リネーム中にファイル名の重複が発生した場合は他のリネームが終了後、再度変更を試みます。


#使い方 (-h --help に説明あり)  

```text
rbrn <mode [args..]> [-t type] [-d dir]  
    <mode>                 現在は -r のみ指定可能
    -r BEFORE [AFTER]      BEFOREをAFTERに変更する、AFTERを省略した場合は削除
    -t TYPE                対象となるファイルの種類を選択(file,dir,all) default is file
    -d DIR                 対象となるディレクトリを指定 default is ./
    -h --help              ヘルプを表示

    BEFOREは独自の正規表現の使用が可能
        ^       先頭に使用するとファイル名の先頭にのみマッチするようになる
        $       末尾に使用するとファイル名の末尾にのみマッチするようになる
        ?       リネーム時に任意の一文字に置き換わる
        *       rubyの.*?と同等、任意の文字列にマッチする
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
* 対象とする文字列にruby同じ正規表現を使えるようにする
* 対象とする文字列にvim風のテキストオブジェクトを使えるようにする
* 変更点などをカラー表示して見やすくする


