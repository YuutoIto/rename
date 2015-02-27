renameはruby2.1以上での動作を確認しています。
使用時は実行パーミッションを付加し、~/binに入れることを推奨します。


使用方法
(-h --help に簡易説明あり)

rbrn directory target-string [-ren]

    directory       リネーム対象のファイルがあるディレクトリ
    target-string   ファイル名の変更する部分文字列(置き換え対象)
    -ren            リネーム方式を指定

    target-stringは独自の正規表現の使用が可能
        ^       target-stringの先頭に使用するとファイル名の先頭にのみマッチするようになる
        $       target-stringの末尾に使用するとファイル名の末尾にのみマッチするようになる
        ?       リネーム時に任意の一文字に置き換わる
        *       置き換え対象を * にマッチした部分にする
    
    -r STR      target-stringにマッチする文字列をSTRに置き換える
    -e          target-stringにマッチする文字列を削除する
    -n [NUM]    target-stringにマッチする文字列をNUMで指定した数値を数え上げした文字列に変更する
                指定した桁数で全てのファイル名を表現できない場合は自動で桁を合わせる
                0000 の場合4桁の0からの数え上げ
                50   の場合2桁の50からの数え上げ
                未指定の場合自動桁合わせ、0からの数え上げ


######使用例######

##対象ディレクトリ
sampled
    WCW000.jpg
    WCW001.jpg
    WCW002.jpg


#1 シンプルな置き換え
rename sampled/ W -r A

sampled
    ACA000.jpg
    ACA001.jpg
    ACA002.jpg


#2 ^を使用した先頭のみの置き換え
rename sampled/ ^W -r A

sampled
    ACW000.jpg
    ACW001.jpg
    ACW002.jpg


#3 $を使用した末尾のみの置き換え
rename sampled/ .jpg$ -r .png

sampled
    WCW000.png
    WCW001.png
    WCW002.png


#4 -n を使用したシンプルな数え上げ
rename sampled/ .jpg -n 00050

sampled
    WCW0000050
    WCW0010051
    WCW0020052


#5 *にマッチした部分の置き換え
rename sampled/ *.jpg -n 0100

sampled
    WCW0100.jpg
    WCW0101.jpg
    WCW0102.jpg


#6 *を使用した文字列と文字列の間の文字列の置き換え
rename sampled/ WCW*.jpg -n 00025

#result
sampled
    WCW00025.jpg
    WCW00026.jpg
    WCW00027.jpg
    #ここではtarget-stringに WCW*.jpgを指定してるが,
    #このようなファイル名の場合本来は ^WCW*.jpg$ と指定するのが好ましい


##複雑な使用例
    以降は変更前のディレクトリ、コマンド、変更後のディレクトリの順で記述

#1 X?Z に当てはまる文字列を全て XYZ に置き換える
sampled
    XAZ0
    XBZ1
    XCZ2

rename sampled/ X?Z -r XYZ

sampled
    XYZ0
    XYZ1
    XYZ2

#2 ? を複数使用して3文字の拡張子のみを.jpgに揃える($が重要)
sampled
    0.png
    1.jpg
    2.bmp
    3.xvsf

rename sampled/ .???$ -r .jpg

sampled
    0.jpg
    1.jpg
    2.jpg
    3.xvsf


#3 2を?ではなく*を使用すると拡張子の文字数に関係なくすべて.jpgになる
sampled
    0.png
    1.jpg
    2.bmp
    3.xvsf

rename sampled/ .*$ -r .jpg

sampled
    0.jpg
    1.jpg
    2.jpg
    3.jpg


#4 ?と*を併用する
sampled
    A0Bccc.jpg
    A1Bddd.jpg
    A2Beee.jpg

rename sampled/ A?B*.jpg -n 40

sampled
    A0B40.jpg
    A1B41.jpg
    A2B42.jpg

#5 *に複数マッチする場合の動作
sampled
    AsssBAwwwwB

rename sampled/ A*B -r @

sampled
    A@BA@B

#6 5で^と$を使用した場合
sampled
    AsssBAwwwwB

rename sampled/ ^A*B$ -r @

sampled
    A@B


######
このようにtarget-stringがファイル名の文字列に複数マッチする場合がるので、
拡張子を変更するときは $ を、
先頭の文字列を変更するときは ^ を使用するように心がける
