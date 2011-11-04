#
# Chef Solo Config File
#

root = File.expand_path(File.dirname(__FILE__))

log_level          :info
log_location       STDOUT
file_cache_path    root
cookbook_path      root + '/../cookbooks'
role_path          root + '/../roles'
ssl_verify_mode    :verify_none
Chef::Log::Formatter.show_time = false
