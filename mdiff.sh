#!/bin/bash
#
# このシェルスクリプトの目的
#  複数のファイルの中身を比較する。一定の命名規則のディレクトリとファイル名であれば
#  ディレクトリ名のパターンの指定と、ファイル名のパターンの指定をすることで抽出したファイルを比較する。
#
# 前提条件1
#  nkfが利用可能であること。
#
# 前提条件２
#  定義ファイルが格納されているディレクトリのファイルリストを作成し、
#  そのパスが変数FILELISTに指定されていること。
#
# 操作説明
#  シェルスクリプトの実行時に第一引数として、ディレクトリ検索パターンを指定する。
#  第二引数として比較対象のファイル名を指定する。
#  ファイル名が系によって異なる場合は正規表現を利用する。
#
# 作成日
#  2016/07/25 aizawa
#
# 更新履歴
#  2016/07/06 aizawa 引数のエラー処理を追加

# 変数の設定
COMDIR="/"
FILELIST="~/filelist.txt"
COUNT=0

# ファイルが格納されているディレクトリの検索パターンの設定
readonly FARGS=("E" "C" "J" "U")
readonly GREPP=("*E*" "*C*" "*J*" "*U*")

# 引数の数のエラーチェック
if [ $# -ne 2 ] ; then
    echo "引数を指定してください。引数1(E|C|J|U)、引数2(FILENAME)";exit 1
fi

# 第一引数のエラーチェックと検索結果の変数への格納
case $1 in
    ${FARGS[0]} ) FCHECK=`grep $FILELIST -e $2 | grep -e ${GREPP[0]}`  ;;
    ${FARGS[1]} ) FCHECK=`grep $FILELIST -e $2 | grep -e ${GREPP[1]}` ;;
    ${FARGS[2]} ) FCHECK=`grep $FILELIST -e $2 | grep -e ${GREPP[2]}` ;;
    ${FARGS[3]} ) FCHECK=`grep $FILELIST -e $2 | grep -e ${GREPP[3]}` ;;
    * ) echo "引数1が不適切です。E or C or J or U が指定可能です。" && exit 1;;
esac

# 検索結果を配列に格納し、配列数＝検索したファイル数を変数に格納
BARRAY=($FCHECK)
ACOUNT=`expr ${#BARRAY[*]} - 1`

# 第二引数のエラーチェックと、検索結果による実行可否の確認
if [ ${#BARRAY[*]} -eq 0 ] ; then
    echo "引数2が不適切です。参照可能なファイル名を指定してください。正規表現が利用可能です。";exit 1
else
    echo "指定した名前で${#BARRAY[*]}件のファイルが見つかりました。比較を実行しますか？[y/n]"
    read ANSWER
    case $ANSWER in
        "y" | "yes" | "Y" | "YES" ) echo "比較を開始します。" ;;
        * ) echo "実行を中止します。" && exit 1 ;;
    esac
fi

# 比較の実行。配列0と1、0と2、0と3といった具合に配列の先頭のファイルを基準に比較する
while [ $COUNT -ne $ACOUNT ]
do
    COUNT=`expr $COUNT + 1`
    echo "---------${BARRAY[0]#.*}と${BARRAY[COUNT]#.*}の比較-------------"
    DRESULT=`diff ${COMDIR}${BARRAY[0]#.*} ${COMDIR}${BARRAY[COUNT]#.*} | nkf`
    if test "${DRESULT}" = "" ; then
        echo "No difference!"
    else
        echo "${DRESULT}"
    fi
done
exit 0
