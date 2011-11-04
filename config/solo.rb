#
# Chef Solo Config File
#
require 'fileutils'

root = File.expand_path(File.dirname(__FILE__))

log_level          :info
log_location       STDOUT
file_cache_path    root + '/../../chef-cache'
cookbook_path      root + '/../cookbooks'
role_path          root + '/../roles'
ssl_verify_mode    :verify_none
Chef::Log::Formatter.show_time = false
FileUtils.mkdir_p(file_cache_path)
