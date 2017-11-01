namespace :setup do
    desc "Install packages"
    task :install_packages do
        on roles(:send) do
            execute "sudo apt-get update -q;sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq postfix postfix-mysql"
        end
        on roles(:receive) do
            execute "dpkg -l dovecot;if [ $? -ne 0 ] ; then sudo apt-get update -q;sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq dovecot-imapd dovecot-mysql dovecot-lmtpd ; fi"
        end
        on roles (:db) do
            execute "dpkg -l mysql-server;if [ $? -ne 0 ] ; then sudo apt-get update -q; sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq mysql-client mysql-server; fi"
        end
    end
    
    task :create_sym_links do
        on roles(:send) do
             execute "sudo ln -sf #{current_path}/postfix/* /etc/postfix/"
        end
        on roles(:receive) do
             execute "sudo cp -Rf #{current_path}/dovecot/* /etc/dovecot/"
        end
    end
    task :copy_certificates do
        on roles(:receive) do
            execute "sudo ln -sf #{current_path}/keys/private/mailserver.pem /etc/ssl/private/mailserver.pem;"
            execute "sudo ln -sf #{current_path}/keys/certs/mailserver.pem /etc/ssl/certs/mailserver.pem;"
        end
    end
    task :create_userandgroup do
        on roles(:receive) do
            execute "if [ ! $(getent group vmail) ]; then sudo groupadd vmail;sudo useradd -g vmail vmail -d /var/vmail -m;sudo chown -R vmail.vmail /var/vmail; fi"
        end
    end
    task :create_tables do
        on roles(:db) do
            execute "sudo mysql -u root --password= < #{current_path}/mysql/mailserver.sql"
        end
    end
    task :configure_dns do
        on roles(:staging) do
            execute "echo \"nameserver 192.168.1.12\" | sudo tee /etc/resolv.conf"
            execute "echo \"nameserver 192.168.1.13\" | sudo tee -a /etc/resolv.conf"
        end
    end
    after 'deploy:finished', 'setup:install_packages'
    after 'setup:install_packages', 'setup:create_sym_links'
    after 'setup:create_sym_links', 'setup:copy_certificates'
    after 'setup:copy_certificates', 'setup:create_tables'
    after 'setup:create_tables', 'setup:create_userandgroup'
    after 'setup:create_userandgroup', 'setup:configure_dns'
end
