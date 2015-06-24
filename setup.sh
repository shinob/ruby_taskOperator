#!/bin/sh

libdir="taskOperator/lib"

# データベースファルの作成

sqlite3 ${libdir}/databases/taskOperator.db < ${libdir}/databases/taskOperator.sql

# ファイル属性の変更

chmod 755 taskOperator/*.rb
chmod 777 ${libdir}/databases
chmod 777 ${libdir}/databases/taskOperator.db

# ログファイルの作成

touch ${libdir}/aduser.log
chmod 666 ${libdir}/aduser.log
