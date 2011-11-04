#
# Cookbook Name:: users
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

node[:users][:list].each do |user_name, attrs|
  attrs ||= {}
  user_home = attrs['home'] || attrs[:home] || "/home/#{user_name}"
  user user_name do
    action :create
    shell attrs['shell'] || attrs[:shell] || node[:users][:shell]
    password attrs['password'] || attrs[:password] || node[:users][:password]
    comment attrs['comment'] || attrs[:comment] || node[:users][:comment]
    home user_home
    system attrs['system'] || attrs[:system] || node[:users][:system]
    supports :manage_home => true
  end

  if attrs['ssh_key'] || attrs[:ssh_key]
    directory "#{user_home}/.ssh" do
      owner user_name
      group user_name
      mode "0700"
      action :create
    end

    file "#{user_home}/.ssh/authorized_keys" do
      owner user_name
      group user_name
      mode "0644"
      action :create
      content [attrs['ssh_key'] || attrs[:ssh_key]].flatten.join("\n")
    end
  end
end
