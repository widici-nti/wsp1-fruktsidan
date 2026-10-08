require 'debug'
require 'awesome_print'

class App < Sinatra::Base
  register Sinatra::Reloader

  def db
    return @db if @db

    @db = SQLite3::Database.new(DB_PATH)
    @db.results_as_hash = true

    @db
  end

  def fruit(id)
    @fruit = db.execute('SELECT * FROM products WHERE id=?', id).first
  end

  get '/fruits' do
    @fruits = db.execute('SELECT * FROM products')
    erb(:'fruits/index')
  end

  get '/fruits/new' do
    erb(:'fruits/new')
  end

  post '/fruits' do
    db.execute('INSERT INTO products (name, description, tastiness) VALUES (?, ?, ?)', params.values)
    redirect(:'/fruits')
  end

  get '/fruits/:id/edit' do |id|
    fruit id
    erb(:'fruits/edit')
  end

  post '/fruits/:id/update' do
    db.execute('UPDATE products SET name=?, description=?, tastiness=? WHERE id=?', params.values)
    redirect(:'/fruits')
  end

  get '/fruits/:id' do |id|
    fruit id
    erb(:'fruits/show')
  end

  post '/fruits/:id/delete' do |id|
    db.execute('DELETE FROM products WHERE id=?', id).first
    redirect('/fruits')
  end
end
