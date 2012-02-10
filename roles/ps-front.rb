name "ps-front"
recipes %w{nginx::source git unicorn capistrano sudo users users::mysql}
default_attributes unicorn: { rails_root: '/data/ps/current',
                              socket: '/data/ps/current/tmp/pids/ps.sock' },
                   timestamp: { name: 'US/Pacific' },
                   capistrano: { user: 'deploy', dir: '/data/ps' },
                   authorization: { sudo: { users: %w{deploy vagrant},
                                            passwordless: true } }
