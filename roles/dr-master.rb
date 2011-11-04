name "dr-master"
recipes %w{nginx::source mysql::server git unicorn sudo user ssh_known_hosts}
default_attributes "unicorn" => { :rails_root => "/data/ps/current",
                              :socket => "/data/ps/current/tmp/pids/ps.sock" },
                   "authorization" => { :sudo => { :users => ["doctor"],
                                                   :passwordless => true } }
