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

  def category(id)
    @category = db.execute('SELECT * FROM categories WHERE id=?', id).first
  end

  def fruits
    @fruits = db.execute('SELECT * FROM products')
  end

  def categories
    @categories = db.execute('SELECT * FROM categories')
  end

  get '/fruits' do
    fruits
    erb(:'fruits/index')
  end

  get '/fruits/new' do
    categories
    erb(:'fruits/new')
  end

  post '/fruits' do
    db.execute('INSERT INTO products (name, description, tastiness, category_id) VALUES (?, ?, ?, ?)', params.values)
    redirect(:'/fruits')
  end

  get '/fruits/:id/edit' do |id|
    fruit id
    categories
    erb(:'fruits/edit')
  end

  post '/fruits/:id/update' do
    db.execute('UPDATE products SET name=?, description=?, tastiness=?, category_id=? WHERE id=?', params.values)
    redirect(:'/fruits')
  end

  get '/fruits/:id' do |id|
    fruit id
    category id
    erb(:'fruits/show')
  end

  post '/fruits/:id/delete' do |id|
    db.execute('DELETE FROM products WHERE id=?', id).first
    redirect('/fruits')
  end
end
