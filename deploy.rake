require 'rubygems'
require 'bundler'
Bundler.require
require 'provisioner'

namespace :provision do
  Dir['nodes/*.json'].each do |node|
    node_name = File.basename(node).gsub(/\.[^\.]+$/, '')
    desc "Provisions #{node_name} node"
    task node_name.to_sym do
      provisioner = Provisioner.new(node)
      provisioner.provision!
    end
  end
end
