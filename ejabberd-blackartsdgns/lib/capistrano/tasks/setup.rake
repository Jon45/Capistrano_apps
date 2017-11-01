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
        on roles(:blackartdsgns,:example) do
            execute "sudo systemctl restart #{fetch(:application)}"
        end
    end
    
    task :configure_dns do
        on roles(:staging) do
            execute "echo \"nameserver 192.168.1.12\" | sudo tee /etc/resolv.conf"
            execute "echo \"nameserver 192.168.1.13\" | sudo tee -a /etc/resolv.conf"
        end
    end
    
    task :configure_users do
        on roles(:blackartdsgns) do
            execute "sudo ejabberdctl check_account jon blackartdsgns.com; if [ $? -ne 0 ] ; then sudo ejabberdctl register jon blackartdsgns.com \'1234\'; fi"
        end
        on roles(:example) do
            execute "sudo ejabberdctl check_account estrella example.com; if [ $? -ne 0 ] ; then sudo ejabberdctl register estrella example.com \'1234\'; fi"
        end
    end
    after 'deploy:finished', 'setup:install_packages'
    after 'setup:install_packages', 'setup:copy_config'
    after 'setup:copy_config', 'setup:configure_dns'
    after 'setup:configure_dns', 'setup:configure_users'
end
