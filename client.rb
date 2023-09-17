require 'sinatra'
require 'teeworlds_network'

messages = []
client = TeeworldsClient.new(verbose: false)
client_connected = false
client.set_startinfo(
  name: 'tw-api.',
  clan: 'zillyhuhn.com',
  country: -1,
  body: 'spiky',
  marking: 'duodonny',
  decoration: '',
  hands: 'standard',
  feet: 'standard',
  eyes: 'standard',
  custom_color_body: 0,
  custom_color_marking: 0,
  custom_color_decoration: 0,
  custom_color_hands: 0,
  custom_color_feet: 0,
  custom_color_eyes: 0,
  color_body: 0,
  color_marking: 0,
  color_decoration: 0,
  color_hands: 0,
  color_feet: 0,
  color_eyes: 0
)

client.on_connected do
  client_connected = true
end

client.on_disconnect do
  client_connected = false
end

client.on_chat do |_, msg|
  author = ''
  author = msg.author.name if msg.author
  messages << {author:, message: msg.message}
end

get '/' do
  @hostname = ENV['HOSTNAME'] || 'http://localhost:4567'
  erb :index
end

get '/style.css' do
  send_file File.expand_path('style.css', settings.public)
end

post '/disconnect' do
  unless client_connected
    return 'Client not connected'
  end
  client_connected = false
  client.disconnect
  'OK'
end

post '/connect' do
  if client_connected
    return 'Already connected'
  end
  host = params[:host] || 'localhost'
  port = params[:port] || 8303
  client.connect(host, port.to_i, detach: true)
  'OK'
end

get '/messages' do
  content_type :json
  messages.to_json
end

post '/messages' do
  msg = params[:message]
  if msg.nil? || msg.empty?
    return 'Missing parameter message'
  end
  unless client_connected
    return 'Client is not connected'
  end
  client.send_chat(msg)
end
