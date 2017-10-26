namespace :setup do
    desc "Install packages"
    task :install_packages do
        on roles(:blackartdsgns,:example) do
            execute "dpkg -l ejabberd;if [ $? -ne 0 ] ; then sudo apt-get update -q;sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ejabberd; fi"
        end
    end
    
    task :copy_config do
        on roles(:blackartdsgns) do
             execute "sudo cp #{current_path}/xmppBlackartdsgns/ejabberd.yml /etc/ejabberd/ejabberd.yml"
        end
        on roles(:example) do
             execute "sudo cp #{current_path}/xmppExample/ejabberd.yml /etc/ejabberd/ejabberd.yml"
        end
    end
    after 'deploy:finished', 'setup:install_packages'
    after 'setup:install_packages', 'setup:copy_config'
end
