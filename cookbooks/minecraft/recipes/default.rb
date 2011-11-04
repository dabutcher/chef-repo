#
# Cookbook Name:: minecraft
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
include_recipe "java"

user node[:minecraft][:user] do
  action :create
  system true
  shell "/bin/false"
end

directory node[:minecraft][:dir] do
  owner node[:minecraft][:user] 
  mode "0755"
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/minecraft_server.jar" do
  source node[:minecraft][:jar_location] 
  action :create_if_missing
end

bash "copy_jar" do
  cwd Chef::Config[:file_cache_path]
  code "cp minecraft_server.jar #{node[:minecraft][:dir]}"
  creates "#{node[:minecraft][:dir]}/minecraft_server.jar"
end

file node[:minecraft][:dir] + '/minecraft_server.jar' do
  owner node[:minecraft][:user]
  group node[:minecraft][:user]
  mode "0755"
end

service "minecraft" do
  provider Chef::Provider::Service::Upstart
  supports :start => true, :stop => true
end

template "server.properties" do
  path "#{node[:minecraft][:dir]}/server.properties"
  source "server.properties.erb"
  owner node[:minecraft][:user]
  group node[:minecraft][:user]
  mode "0644"
end

template "admins.txt" do
  path "#{node[:minecraft][:dir]}/admins.txt"
  source "admins.txt.erb"
  owner node[:minecraft][:user]
  group node[:minecraft][:user]
  mode "0644"
end

template "minecraft.upstart.conf" do
  path "/etc/init/minecraft.conf"
  source "minecraft.upstart.conf.erb"
  owner node[:minecraft][:user]
  group node[:minecraft][:user]
  mode "0644"
end

service "minecraft" do
  action [:enable, :start]
end
