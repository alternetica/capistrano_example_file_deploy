require 'erb'

#References.
#name: Cesar A. P. Sulbaran
#alias: casp
#twitter: @ cesulbaran
#emails: cesulbaran@gmail.com

#Domain and system parameters
set :application, "xxxx.com"
set :production_domain, 'xxxx.com'
set :test_domain, 'test.xxxx.com'
set :development_domain, 'development.xxxx.com'
set :database_driver, 'mysql2' # pg, mysql2,
# server details user hosting
set :use_sudo, false
set :user, "user_server_hosting"                   # ssh user production server.
set :password, "password"                          # password user
default_run_options[:pty] = true
ssh_options[:forward_agent] = true

#Repository Parameters
set :scm, :git
set :scm_username, "user_github"                      # github user
set :repository, "git@github.com:example/Mysite.git"  # github repository
set :scm_verbose, true
set :branch, "master"                                 # branch
set :deploy_via, :remote_cache

task :development do                                  #-> config test
  # server_mysql config
  set :user_driver, 'user_driver_development'                       #-> user mysql2
  set :password_driver,'passord_driver_development'                 #-> password
  set :server_driver,'host_driver_db_development'                   #-> host database mysql
  set :databasename, 'database_name_driver_development'            #-> database name
  set :rails_env, "production"
  set :deploy_to, "/home/#{user}/#{development_domain}"
  set :deploy_via, :remote_cache
  role :web, "#{development_domain}"                          # Your HTTP server, Apache/etc
  role :app, "#{development_domain}"                          # This may be the same as your `Web` server
  role :db,  "#{development_domain}", :primary => true # This is where Rails migrations will run
  role :db,  "#{development_domain}"
end

task :tests do
  # server_mysql config
  set :user_driver, 'user_driver_test'                       #-> user mysql2
  set :password_driver,'passord_driver_test'                 #-> password
  set :server_driver,'host_driver_db_test'                   #-> host database mysql
  set :databasename, 'database_name_driver_development'            #-> database name
  set :rails_env, "production"
  set :deploy_to, "/home/#{user}/#{test_domain}"
  set :deploy_via, :remote_cache
  role :web, "#{test_domain}"                          # Your HTTP server, Apache/etc
  role :app, "#{test_domain}"                          # This may be the same as your `Web` server
  role :db,  "#{test_domain}", :primary => true # This is where Rails migrations will run
  role :db,  "#{test_domain}"

end

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
task :production do                                          #-> config production
  set :user_driver, 'user_driver_production'                       #-> user mysql2
  set :password_driver,'passord_driver_production'                 #-> password
  set :server_driver,'host_driver_db_production'                   #-> host database mysql
  set :databasename, 'database_name_driver_production'            #-> database name
  set :rails_env, "production"
  set :deploy_to, "/home/#{user}/#{test_domain}"
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
   task :start do ; end
   task :stop do ; end

   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end


   task :update_links do
     run "ln -s #{shared_path}/config/database.yml #{current_path}/config/database.yml"
     run "ln -s #{shared_path}/uploads #{current_path}/public/uploads"
     run "ln -s #{shared_path}/reports #{current_path}/public/reports"
   end
 end

 #after 'deploy:update_code','deploy:update_links'

 desc "initialization files and directories by default."
 namespace :setup do

   task :all do
     uploads
     reports
     database
   end

   task :clean_all do
     clean_current
     clean_release
     clean_shared
     all
   end

   task :clean_shared do
     run "rm -rf  #{shared_path}/*"
   end

   task :clean_current do
     run "rm -rf  #{current_path}/*"
   end

   task :clean_release do
     run "rm -rf  #{release_path}/*"
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
  adapter: #{database_driver}
  encoding: utf8
  reconnect: false
  pool: 5
  database: #{databasename}
  host: #{server_driver}
  username: #{user_driver}
  password: #{password_driver}
    EOF
    run "mkdir -p #{shared_path}/config"
    put database.result, "#{shared_path}/config/database.yml"
   end
 end

