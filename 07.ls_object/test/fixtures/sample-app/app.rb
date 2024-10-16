# frozen_string_literal: true

require 'pg'
require 'sinatra'
require 'sinatra/reloader'

DB_NAME = 'memo_app'
USER = 'postgres'
TABLE_NAME = 'memos'

conn = PG.connect(dbname: DB_NAME, user: USER)

def fetch_all_memos(conn)
  conn.exec("SELECT * FROM #{TABLE_NAME}").values.map { |id, title, content| { id:, title:, content: } }
end

def create_memo(conn, params)
  conn.exec_params("INSERT INTO #{TABLE_NAME} (title, content) VALUES ($1, $2)", [params[:title], params[:content]])
end

def select_memo_by_id(conn, memo_id)
  conn.exec_params("SELECT * FROM #{TABLE_NAME} WHERE id = $1", [memo_id]).values.map { |id, title, content| { id:, title:, content: } }[0]
end

def update_memo(conn, memo_id, params)
  conn.exec_params("UPDATE #{TABLE_NAME} SET (title, content) = ($1, $2) WHERE id = $3", [params[:title], params[:content], memo_id])
end

def delete_memo(conn, memo_id)
  conn.exec_params("DELETE FROM #{TABLE_NAME} WHERE id = $1", [memo_id])
end

get '/memos' do
  @title = 'memo list'
  @memos = fetch_all_memos(conn)
  erb :index
end

get '/memos/new' do
  @title = 'new memo'
  erb :new
end

post '/memos' do
  create_memo(conn, params)
  redirect '/memos'
end

get '/memos/:id' do |memo_id|
  @title = 'show memo'
  @memo = select_memo_by_id(conn, memo_id)
  raise Sinatra::NotFound if @memo.nil?

  erb :show
end

get '/memos/:id/edit' do |memo_id|
  @title = 'edit memo'
  @memo = select_memo_by_id(conn, memo_id)
  raise Sinatra::NotFound if @memo.nil?

  erb :edit
end

patch '/memos/:id' do |memo_id|
  update_memo(conn, memo_id, params)
  redirect '/memos'
end

delete '/memos/:id' do |memo_id|
  delete_memo(conn, memo_id)
  redirect '/memos'
end

not_found do
  erb :not_found, layout: false
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end
