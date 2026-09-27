# frozen_string_literal: true

require 'bundler/setup'
require 'ruby_cowsay'

steg = Cow.new({ cow: 'stegosaurus' })
puts steg.say('hello world! :D')
