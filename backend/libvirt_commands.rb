require 'securerandom'
require 'open3'
require 'json'

module LibvirtCommands
  TOKEN_STORE = "/tmp/vm_console_tokens.json"

  module_function

  def run(cmd)
    out, err, st = Open3.capture3(cmd)
    raise "Command failed: #{cmd}\n#{err}" unless st.success?
    out.strip
  end

  def create_vm(name)
    raise 'name required' unless name

    scripts_dir = File.expand_path('../../scripts', __dir__)
    cmd = "bash #{scripts_dir}/create_vm.sh #{name}"
    run(cmd)
  end

  def list_vms
    out = run('virsh list --all')
    out.split('\n')[2..-1]&.map(&:strip) || []
  end

  def get_vnc_port(name)
    xml = run("virsh dumpxml #{name}")
    match = xml.match(/<graphics type='vnc' port='(\d+)'/)
    match ? match[1].to_i : nil
  end

  def generate_console_token(name, port)
    token = SecureRandom.hex(16)
    data = {}
    if File.exist?(TOKEN_STORE)
      data = JSON.parse(File.read(TOKEN_STORE))
    end
    data[token] = { 'name' => name, 'port' => port, 'expires_at' => (Time.now + 60).to_i }
    File.write(TOKEN_STORE, JSON.pretty_generate(data))
    token
  end

  def start_websockify_for_vm(name, port, token)
    scripts_dir = File.expand_path('../../scripts', __dir__)
    cmd = "bash #{scripts_dir}/start_console.sh #{name} #{port} #{token} &"
    run(cmd)
  end
end
