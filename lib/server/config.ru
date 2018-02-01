require 'rubygems'
require 'bundler'
Bundler.require

require './server_app.rb'
run Sinatra::Application
