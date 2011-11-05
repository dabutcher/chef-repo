class Provisioner
  attr_accessor :node_name, :node_path, :ruby_version

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

      [@host].flatten.each do |host|
        upload_tar host
        run_chef host
      end
    ensure
      @tarball.unlink
    end
  end

  private
  def upload_tar(host)
    Net::SCP.start(host, @username, @options) do |scp|
      puts "Uploading tar"
      scp.upload! @tarball.path, @tmp_file
    end
  end

  def run_chef(host)
    Net::SSH.start(host, @username, @options) do |ssh|
      unless ssh.exec! "which chef-solo && echo 1"
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
      sudo aptitude install -y build-essential make \
      zlib1g zlib1g-dev libreadline5 libreadline5-dev libssl-dev
      #{install_ruby}
      sudo gem install --no-rdoc --no-ri chef ruby-shadow
    EOH
  end

  def install_ruby
    case ruby_version
    when '1.9.2'
      'mkdir ruby-src && cd ruby-src
       wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p290.tar.gz
       tar zxf ruby-1.9.2-p290.tar.gz && cd ruby-1.9.2-p290
       ./configure && make && sudo make install
       cd ..
       wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.10.tgz
       tar zxf rubygems-1.8.10.tgz && cd rubygems-1.8.10
       sudo ruby setup.rb
       cd ..'
    when '1.8.7', '1.8'
    when 'ree-1.8.7', 'ree'
    when 'system1.9'
    else # system 1.8
      'sudo aptitude install -y ruby rubygems ruby-dev libopenssl-ruby1.8 &&
       sudo gem install --no-rdoc --no-ri rubygems-update &&
       sudo /var/lib/gems/1.8/bin/update_rubygems'
    end
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
      cd ~/chef && sudo chef-solo\
        -c config/solo.rb -j #{node_path}
    EOH
  end

  def ohai(*msg)
    puts "=> " + msg.join(" ")
  end

  def extract_properties(hash)
    raise unless hash['provisioner']
    @username = ENV['username'] || ENV['USERNAME'] ||
      hash['provisioner']['username'] || raise
    @host = ENV['host'] || ENV['HOST'] ||
      hash['provisioner']['host'] || raise
    @ruby_version = ENV['ruby'] || ENV['RUBY'] ||
      hash['provisioner']['ruby'] || 'system'
    options = hash['provisioner']['options'] || {}
    @options = Hash[*options.map { |k,v| [k.to_sym, v] }.flatten]
    @options.merge!(:keys => Dir['keys/**/*.pem'])
  end
end
