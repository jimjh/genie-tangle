require 'bundler/capistrano'

set :application,   'genie-tangle'
set :repository,    'git@github.com:jimjh/genie-tangle.git'
set :user,          'passenger'
set :default_shell, '/bin/bash -l'
set :scm,           'git'
set :deploy_via,    :remote_cache
set :branch,        'master'

set :use_sudo,      false
set :keep_releases, 5

set :app_port,      5379
set :faye_port,     3400

set :secrets,       %w[secrets.yml tangle.pem]

role :app, 'beta.geniehub.org'

after 'deploy:update',  'deploy:secrets'
after 'deploy:restart', 'deploy:cleanup'
after 'deploy:setup',   'deploy:upstart'

def with_user(user)
  old_user = user
  set :user, user
  close_sessions
  yield
  set :user, old_user
  close_sessions
end

def close_sessions
  sessions.values.each { |session| session.close }
  sessions.clear
end

# Same as +put+, but use sudo to move the file to a privileged directory.
# @option [String] opts :sudoer      name of user with sudo privileges
def sudo_put(data, path, opts = {})
  sudoer = opts.delete(:sudoer) || user
  filename = File.basename path
  dirname  = File.dirname  path
  temp     = "#{shared_path}/#{filename}"
  put data, temp, opts
  with_user sudoer do
    run "#{sudo} mv #{temp} #{dirname}"
  end
end

namespace :deploy do

  task :start do
    with_user('codex') { run 'sudo service tangle start' }
  end

  task :stop do
    with_user('codex') { run 'sudo service tangle stop' }
  end

  task :restart, roles: :app, except: { no_release: true } do
    with_user('codex') { run 'sudo service tangle restart' }
    with_user('passenger') {}
  end

  task :secrets do
    secrets.each do |secret|
      upload("#{fetch(:template_dir, 'config')}/#{secret}", "#{shared_path}/config/#{secret}")
      run "ln -fs -- #{shared_path}/config/#{secret} #{release_path}/config"
    end
  end

  task :upstart do
    location = fetch(:template_dir, 'config') + '/tangle.conf'
    template = File.read location
    config   = ERB.new template
    sudo_put config.result(binding), '/etc/init/tangle.conf', sudoer: 'codex'
  end

end
