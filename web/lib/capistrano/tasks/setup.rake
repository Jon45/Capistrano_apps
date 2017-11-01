namespace :setup do
    desc "Install packages"
    task :install_packages do
        on roles(:wordpress) do
            execute "sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq php php7.0 php-pear php7.0-mysql php-zip libapache2-mod-php7.0"
        end
        on roles(:prestashop) do
            execute "sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq php7.0 php7.0-mysql php7.0-gd php7.0-curl php-ssh2 libssh2-1"
        end
        on roles(:db) do
            execute "sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq mysql-client mysql-server"
        end
    end
    
    #task :create_sym_links do
    #    on roles(:wordpress) do
    #         execute "sudo ln -sf #{current_path}/wordpress/wordpress.conf /etc/apache2/sites-available/"
    #         execute "sudo ln -sf #{current_path}/wordpress/wordpress /var/www/html/"
    #    end
    #   on roles(:prestashop) do
    #        execute "sudo ln -sf #{current_path}/prestashop/prestashop.conf /etc/apache2/sites-available/"
    #         execute "sudo ln -sf #{current_path}/prestashop/prestashop /var/www/html/"
    #    end
    #end
    
    task :copy_config do
        on roles(:wordpress) do
             execute "sudo cp -f #{current_path}/wordpress/wordpress.conf /etc/apache2/sites-available/"
             execute "sudo cp -Rf #{current_path}/wordpress/wordpress /var/www/html/"
        end
       on roles(:prestashop) do
            execute "sudo cp -f #{current_path}/prestashop/prestashop.conf /etc/apache2/sites-available/"
             execute "sudo cp -Rf #{current_path}/prestashop/prestashop /var/www/html/"
             execute "sudo a2enmod rewrite"
        end
    end
    
    task :configure_permissions do
        on roles(:prestashop) do
            execute "sudo chown www-data.www-data -Rf /var/www/html/prestashop"
        end
    end
    
    task :configure_database do
        on roles (:db) do
            execute "sudo mysql -u root --password= < #{current_path}/prestashop/prestaShop.sql"
            execute "sudo mysql -u root --password= < #{current_path}/wordpress/prestaShop.sql"
        end
    end
    
    task :change_config do
        on roles(:staging) do
            on roles(:prestashop) do
                execute "sudo sed -i 's/prestashop.blackartdsgns.com/prestashop-staging.blackartdsgns.com/g' /etc/apache2/sites-available/prestashop.conf"
                execute "sudo mysql -u root --password= < #{current_path}/prestashop/prestashop-staging.sql"
            end
            on roles (:wordpress) do
                execute "sudo sed -i 's/www.blackartdsgns.com/www-staging.blackartdsgns.com/g' /etc/apache2/sites-available/wordpress.conf"
                execute "sudo mysql -u root --password= < #{current_path}/wordpress/wordpress-staging.sql"
            end
        end
    end
    
    task :enable_site do
        on roles (:prestashop) do
            execute "sudo a2ensite prestashop.conf"
        end
        on roles (:wordpress) do
            execute "sudo a2ensite wordpress.conf"
        end
    end

    
    after 'deploy:finished', 'setup:install_packages'
    after 'setup:install_packages', 'setup:copy_config'
    after 'setup:copy_config', 'setup:configure_permissions'
    after 'setup:configure_permissions', 'setup:configure_database'
    after 'setup:configure_database', 'setup:change_config'
    after 'setup:change_config', 'setup:enable_site'
end
