require 'sinatra'
require 'json'
require_relative 'libvirt_commands'

set :bind, '0.0.0.0'
set :port, 4567

post '/vms' do
  payload = JSON.parse(request.body.read)
  name = payload['name'] || "vm-#{Time.now.to_i}"

  begin
    LibvirtCommands.create_vm(name)
    status 201
    { status: 'created', name: name }.to_json
  rescue => e
    status 500
    { error: e.message }.to_json
  end
end

get '/vms' do
  content_type :json
  { vms: LibvirtCommands.list_vms }.to_json
end

post '/vms/:name/console' do
  name = params['name']
  begin
    port = LibvirtCommands.get_vnc_port(name)
    raise "VM not found or no vnc" unless port

    token = LibvirtCommands.generate_console_token(name, port)
    LibvirtCommands.start_websockify_for_vm(name, port, token)

    { url: "http://#{request.host}:6080/vnc.html?token=#{token}", token: token }.to_json
  rescue => e
    status 500
    { error: e.message }.to_json
  end
end
