#!/bin/sh

# データベースファルの作成

sqlite3 taskOperator/lib/databases/taskOperator.db < taskOperator/lib/databases/taskOperator.sql

# ファイル属性の変更

chmod 755 taskOperator/*.rb
chmod 777 taskOperator/lib/databases
chmod 777 taskOperator/lib/databases/taskOperator.db

