namespace :setup do
    desc "Install packages"
    task :install_packages do
        on roles(:all) do
            execute "dpkg -l #{fetch(:application)};if [ $? -ne 0 ] ; then sudo apt-get update -q;sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq #{fetch(:application)}; fi"
        end
    end
    
    task :create_sym_links do
        on roles(:primario) do
             execute "sudo ln -sf #{current_path}/bind_primario/* /etc/bind/"
        end
        on roles(:primario_staging) do
             execute "sudo ln -sf #{current_path}/bind_primario_staging/* /etc/bind/"
        end
        on roles(:secundario) do
             execute "sudo ln -sf #{current_path}/bind_secundario/* /etc/bind/"
        end
        on roles(:secundario_staging) do
             execute "sudo ln -sf #{current_path}/bind_secundario_staging/* /etc/bind/"
        end
    end
    after 'deploy:finished', 'setup:install_packages'
    after 'setup:install_packages', 'setup:create_sym_links'
end
