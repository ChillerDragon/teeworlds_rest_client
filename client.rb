require 'teeworlds_network'

client = TeeworldsClient.new(verbose: false)
at_exit { client.disconnect }

require 'sinatra'

messages = []
inp_left_ticks = 0
inp_right_ticks = 0
inp_jump_ticks = 0
client_connected = false
client.set_startinfo(
  name: 'zillyhuhn.com',
  clan: 'tw-api',
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

client.on_tick do
  send_inp = false
  dir = 0
  jmp = 0
  inp_left_ticks -= 1
  inp_right_ticks -= 1
  inp_jump_ticks -= 1
  if inp_left_ticks == -1 || inp_right_ticks == -1 || inp_jump_ticks == -1
    # send that we stopped moving
    send_inp = true
  end
  if inp_left_ticks.positive?
    send_inp = true
    dir = -1
  end
  if inp_right_ticks.positive?
    send_inp = true
    dir = 1
  end
  if inp_jump_ticks.positive?
    send_inp = true
    jmp = 1
  end
  # puts send_inp
  # next unless send_inp

  client.send_input(
        direction: dir,
        target_x: 10,
        target_y: 10,
        jump: jmp,
        fire: 0,
        hook: 0,
        player_flags: 0,
        wanted_weapon: 0,
        next_weapon: 0,
        prev_weapon: 0)
end

get '/' do
  @hostname = ENV['HOSTNAME'] || 'http://localhost:4567'
  erb :index
end

get '/style.css' do
  send_file File.expand_path('style.css', settings.public)
end

post '/disconnect' do
  client_connected = false
  client.disconnect
  'OK'
end

post '/connect' do
  host = params[:host] || 'localhost'
  port = params[:port] || 8303
  puts "host='#{host}' port='#{port}'"
  if client_connected
    return 'Already connected'
  end
  client.connect(host, port.to_i, detach: true)
  'OK'
end

post '/jump' do
  ticks = params[:ticks] || 0
  ticks = ticks.to_i
  inp_jump_ticks = ticks
  'OK'

end

post '/left' do
  ticks = params[:ticks] || 0
  ticks = ticks.to_i
  inp_left_ticks = ticks
  'OK'
end

post '/right' do
  ticks = params[:ticks] || 0
  ticks = ticks.to_i
  inp_right_ticks = ticks
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
  puts "msg=#{msg}"
  unless client_connected
    return 'Client is not connected'
  end
  client.send_chat(msg)
end
