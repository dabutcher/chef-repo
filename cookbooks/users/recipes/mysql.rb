#
# Cookbook Name:: users
# Recipe:: mysql
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

if node[:mysql][:manage_users] && node[:mysql][:server_root_password]
  mysql_password = node[:mysql][:server_root_password]
  node[:users][:list].each do |user_name, attrs|
    next unless attrs[:mysql]
    [attrs[:mysql]].flatten.each do |db|
      execute "grant-#{user_name}-#{db}-perms" do
        command <<-EOL
          /usr/bin/mysql -u root -p#{mysql_password} -D mysql -r -B -N -e \
          \"GRANT ALL ON #{db}.* to '#{user_name}'@'localhost'\"
        EOL
        action :run
        not_if do
          `/usr/bin/mysql -u root -p#{mysql_password} -D mysql -r -B -N -e \
          \"SELECT COUNT(*) FROM user where User='#{user_name}' and Host = \
          'localhost'"`.to_i.zero?
        end
      end
    end
  end
end
