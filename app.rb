require 'debug'
require "awesome_print"

class App < Sinatra::Base
    register Sinatra::Reloader

    def db
      return @db if @db

      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    get '/fruits' do
      @fruits = db.execute('SELECT * FROM products')
      erb(:"fruits/index")
    end

    get '/fruits/:id' do | id |
      @fruit = db.execute('SELECT * FROM products WHERE id=?',id).first
    erb(:"fruits/show")
  end
end
