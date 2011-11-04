#
# Cookbook Name:: nodejs
# Recipe:: default
#
# Copyright 2011, Example Com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "build-essential"
include_recipe "python"

packages = value_for_platform(
  ["centos", "redhat", "fedora"] => {'default' => ['openssl-devel', 'gcc-c++'] },
  "default" => ["g++", "openssl", "libssl-dev"]) 

packages.each do |devpkg|
  package devpkg
end

if node[:nodejs][:install_npm]
  package "curl"
end

nodejs_version = node[:nodejs][:version]
node.set[:nodejs][:install_path]    = "/opt/nodejs-v#{nodejs_version}"
node.set[:nodejs][:configure_flags] = ["--prefix=#{node[:nodejs][:install_path]}"]
configure_flags = node[:nodejs][:configure_flags] = node[:nodejs][:configure_flags].join(" ")

remote_file "#{Chef::Config[:file_cache_path]}/node-v#{nodejs_version}.tar.gz" do
  source "http://nodejs.org/dist/node-v#{nodejs_version}.tar.gz"
  action :create_if_missing
end

bash "compile_nodejs_source" do
  cwd Chef::Config[:file_cache_path]
  profile_lines = "export PATH=$PATH:/opt/node-v#{nodejs_version}/bin\n" +
    "export NODE_PATH=/opt/node-v#{nodejs_version}:/opt/node-v#{nodejs_version}/lib/node_modules"
  code <<-EOH
    tar zxf node-v#{nodejs_version}.tar.gz
    cd node-v#{nodejs_version} && ./configure #{configure_flags}
    make && make install
    [ -z `grep "/etc/nodejs-profile" /etc/profile` ] && \
    echo "source /etc/nodejs-profile" >> /etc/profile ; true 
  EOH
end

template "/etc/nodejs-profile" do
  source "profile.erb"
  owner "root"
  group "root"
  mode "0644"
end

if node[:nodejs][:install_npm]
  remote_file "#{Chef::Config[:file_cache_path]}/npm-install.sh" do
    source "http://npmjs.org/install.sh"
    action :create_if_missing
  end

  bash "install_npm" do
    cwd Chef::Config[:file_cache_path]
    code <<-EOH
    source /etc/nodejs-profile >> /etc/profile
    clean=yes sh npm-install.sh
    EOH
  end
end
