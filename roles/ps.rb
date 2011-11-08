name "ps"
recipes %w{nginx::source mysql::server ghostscript git unicorn memcached
           logrotate capistrano sudo xml xslt users users::mysql}
default_attributes "unicorn" => { :rails_root => "/data/ps/current",
                              :socket => "/data/ps/current/tmp/pids/ps.sock" },
                   "timezone" => { :name => "US/Pacific" },
                   "capistrano" => { :user => "deploy",
                                     :dir => "/data/ps" },
                   "authorization" => { :sudo => { :users => ["deploy", "vagrant"],
                                                   :passwordless => true } }
