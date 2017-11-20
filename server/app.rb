require 'sinatra'

get '/' do
    "Root, will list all frameworks and versions"
end

head '/frameworks/:xcodebuild_version/:swift_version/:platform/:name/:repository/:version' do
    status 404
end

post '/frameworks/:xcodebuild_version/:swift_version/:platform/:name/:repository/:version' do
    puts params
end
