class Provisioner
  attr_accessor :node_name, :node_path

  def initialize(file)
    self.node_path = 'nodes/' + File.basename(file)
    self.node_name = File.basename(file).gsub(/\.[^\.]+$/, '')
    json = JSON.parse(File.read(file))
    extract_properties(json)
  end

  def provision!
    begin
      @tarball = Tempfile.new('chef')
      @tarball.write `tar cj .`
      @tarball.close
      @tmp_file = '/tmp/' + @tarball.path.split('/').last

      upload_tar
      run_chef
    ensure
      @tarball.unlink
    end
  end

  private
  def upload_tar
    Net::SCP.start(@host, @username, @options) do |scp|
      puts "Uploading tar"
      scp.upload! @tarball.path, @tmp_file
    end
  end

  def run_chef
    Net::SSH.start(@host, @username, @options) do |ssh|
      unless ssh.exec! "test -f /usr/bin/chef-solo && echo 1"
        puts "Installing needed tools"
        ssh_exec(ssh, install_tools_script)
      end

      puts "Clonning chef folder"
      ssh_exec(ssh, clone_chef_script)

      puts "Running chef"
      ssh_exec(ssh, run_chef_script)
    end
  end

  def ssh_exec(ssh, cmd)
    ssh.exec! cmd do |ch, stream, data|
      ohai(data)
    end
  end

  def install_tools_script
    <<-EOH
      sudo export DEBIAN_FRONTEND=noninteractive
      sudo aptitude update &&
      sudo apt-get -o Dpkg::Options::="--force-confnew" \
          --force-yes -fuy dist-upgrade &&
      sudo aptitude install -y ruby rubygems ruby-dev libopenssl-ruby1.8 make &&
      sudo gem install --no-rdoc --no-ri rubygems-update
      sudo /var/lib/gems/1.8/bin/update_rubygems
      sudo gem install --no-rdoc --no-ri chef
    EOH
  end

  def clone_chef_script
    <<-EOH
      sudo rm -rf ~/chef &&
      mkdir ~/chef &&
      cd ~/chef &&
      tar xf #{@tmp_file} &&
      rm #{@tmp_file}
    EOH
  end

  def run_chef_script
    <<-EOH
      cd ~/chef && sudo /usr/bin/chef-solo\
        -c config/solo.rb -j #{node_path}
    EOH
  end

  def ohai(*msg)
    puts "=> " + msg.join(" ")
  end

  def extract_properties(hash)
    raise unless hash['credentials']
    @username = ENV['username'] || ENV['USERNAME'] ||
      hash['credentials']['username'] || raise
    @host = ENV['host'] || ENV['HOST'] ||
      hash['credentials']['host'] || raise
    options = hash['credentials']['options'] || {}
    @options = Hash[*options.map { |k,v| [k.to_sym, v] }.flatten]
    @options.merge!(:keys => Dir['keys/**/*.pem'])
  end
end
