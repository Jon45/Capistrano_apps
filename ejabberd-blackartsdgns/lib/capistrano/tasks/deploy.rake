namespace :deploy do

  desc "Makes sure local git is in sync with remote."
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} XMPP server."
    task command do
      on roles(:blackartdsgns,:example) do
        execute "sudo systemctl #{command} #{fetch(:application)}"
      end
    end
  end
  
  before :deploy, "deploy:check_revision"
  after :rollback, "deploy:restart"

end
