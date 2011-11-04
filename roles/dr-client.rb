name "dr-client"
recipes %w{nodejs git sudo xml xslt users}
default_attributes "authorization" => { :sudo => { :users => ["doctor", "vagrant"],
                                                   :passwordless => true } }
