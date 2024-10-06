#!/bin/bash

USER='postgres'
DB_NAME='memo_app'
TABLE_NAME='memos'

CREATE_TABLE_SQL="CREATE TABLE ${TABLE_NAME} (
  id serial NOT NULL,
  title varchar(50),
  content varchar(500),
  PRIMARY KEY (id)
);"

createdb $DB_NAME -U $USER
psql $DB_NAME -U $USER -c "$CREATE_TABLE_SQL"
