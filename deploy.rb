require 'erb'
set :application, "application"                     # Name of Application
set :production_domain, 'production_domain.com'     # Domain of server production
set :test_domain, 'test_domain.com'                 # Domain of server test
# server details
set :use_sudo, false
set :user, "user_server_hosting"                   # ssh user production server.
set :password, "password"                          # password user
default_run_options[:pty] = true
ssh_options[:forward_agent] = true


set :scm, :git
set :scm_username, "user_github"                      # github user
set :repository, "git@github.com:example/Mysite.git"  # github repository
set :scm_verbose, true
set :branch, "master"                                 # branch
set :deploy_via, :remote_cache

task :development do                                  #-> config test
  # server_mysql config
  set :user_mysql, 'user_mysql_test'                       #-> user mysql2
  set :password_mysql,'passord_mysql_test'                 #-> password
  set :server_mysql,'host_mysql_db_test'                   #-> host database mysql
  set :databasename, 'database_name_mysql_test'            #-> database name
  set :rails_env, "production"
  set :deploy_to, "/home/#{user}/#{test_domain}"       # path for deploy
  set :deploy_via, :remote_cache
  role :web, "#{test_domain}"                          # Your HTTP server, Apache/etc
  role :app, "#{test_domain}"                          # This may be the same as your `Web` server
  role :db,  "#{test_domain}", :primary => true # This is where Rails migrations will run
  role :db,  "#{test_domain}"

end

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
task :production do                                          #-> config production
  # server_mysql config
  set :user_mysql, 'user_mysql_production'
  set :password_mysql,'password_mysql_production'
  set :server_mysql,'host_mysql_db_production'
  set :databasename, 'database_name_mysql_production'
  set :rails_env, "production"
  set :deploy_to, "/home/#{user}/#{production_domain}"
  set :deploy_via, :remote_cache

  role :web, "#{production_domain}"                          # Your HTTP server, Apache/etc
  role :app, "#{production_domain}"                          # This may be the same as your `Web` server
  role :db,  "#{production_domain}", :primary => true # This is where Rails migrations will run
  role :db,  "#{production_domain}"
end

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

 namespace :deploy do
   task :start do
     update_links
   end
   task :stop do ; end

   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end


   task :update_links do
     run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
     run "ln -s #{shared_path}/uploads #{current_path}/public/uploads"
     run "ln -s #{shared_path}/reports #{current_path}/public/reports"
   end
 end

 after 'deploy:update_code','deploy:update_links'

 desc "initialization files and directories by default."
 namespace :setup do
   task :all do
     uploads
     reports
     database
   end

   desc "uploads initialization."
   task :uploads do
   run "if [ -d  #{shared_path}/uploads ] ;then
          echo 'directory already exists';
        else
          mkdir -p #{shared_path}/uploads;
        fi
        "
   end

   desc "initialization file reports."
   task :reports do
   run "if [ -d  #{shared_path}/reportss ] ;then
          echo 'directory already exists';
        else
          mkdir -p #{shared_path}/reports;
        fi
        "
   end

  desc "initialization files and directories database."
   task :database do
    database = ERB.new <<-EOF
production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  pool: 5
  database: #{databasename}
  host: #{server_mysql}
  username: #{user_mysql}
  password: #{password_mysql}
    EOF
    run "mkdir -p #{shared_path}/config"
    put database.result, "#{shared_path}/config/database.yml"
   end
 end

