#!/usr/bin/env ruby
# ~*~ encoding: utf-8 ~*~
require 'faye'
require 'sinatra'
require 'pty'
require 'json'
require 'set'

load './ssh.rb'

class TTYExtension

  def initialize
    @terms = {}
    @clients = {}
    super
  end

  def incoming(message, callback)
    case message['channel']
    when '/create' then handle_create message
    when '/input'  then handle_input  message
    when '/kill'   then handle_kill   message
    when '/meta/disconnect' then handle_disconnect message
    end
    callback.call(message)
  end

  private

  def handle_create(message)
    request, client = message['data'], message['clientId']
    args, callback  = request['args'], request['callback']
    r, w, id = open_ssh(*args) # TODO: config
    @terms[id] = { r: r, w: w, owner: client }
    @clients[client] ||= Set.new
    @clients[client] << id
    r.on_close { $client.publish('/kill', id) }
    r.on_data  { |data| $client.publish('/data', { id: id, data: data }) }
    reply callback: callback, args: { id: id, pty: id, process: 'bash' }
  end

  def handle_input(message)
    request = message['data']['args']
    term    = @terms[request.shift]
    term[:w] << request.join if term
  end

  def handle_kill(message)
    # FIXME security (kills are only allowed from server and owner)
    kill message['data']
  end

  def handle_disconnect(message)
    client = message['clientId']
    if ptys = @clients[client] then ptys.each { |pty| kill pty } end
  end

  def kill(pty)
    return unless term = @terms.delete(pty)
    term[:w].close
    if ptys = @clients[term[:owner]]
      ptys.delete(pty)
      @clients.delete(term[:owner]) if ptys.empty?
    end
  end

  def reply(opts)
    $client.publish('/callback', opts.to_json)
  end

end

Faye::WebSocket.load_adapter('thin')
use Faye::RackAdapter, mount: '/faye', timeout: 25, extensions: [TTYExtension.new]

$client = Faye::Client.new('http://localhost:4567/faye')

set :static, true
set :public_folder, 'static'

get '/' do
  send_file 'static/index.html'
end
