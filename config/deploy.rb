# config valid only for Capistrano 3.1
lock '3.1.0'

set :deploy_to, '/home/dev/elza'
set :user, "dev"
set :rails_env, "development"
set :deploy_via, :copy

## Repo settings
set :scm, :git
set :application, 'Elza'
set :repo_url, 'git@github.com:Bacchuser/bacchusproject.git'

set :linked_dirs, %w{tmp/pids tmp/sockets log}

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  task :restart_nginx do
    on roles(:web) do
      execute '#{sudo} service nginx stop',raise_on_non_zero_exit: false
      execute '#{sudo} service nginx start',raise_on_non_zero_exit: false
    end
  end

  desc 'Run Bundle install TASK'
  task :bundleInstall do
    on roles(:web) do
      execute "source /etc/profile.d/rvm.sh && cd #{deploy_to}/current && bundle install",raise_on_non_zero_exit: false
    end
  end

  after :bundleInstall, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 2 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :publishing, :restart_nginx
  after :restart_nginx, :bundleInstall
end
