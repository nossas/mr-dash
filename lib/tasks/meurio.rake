namespace :mrdash do
  task :sync_with_meurio, :needs => :environment do
    puts "Syncing with Meu Rio..."
    User.sync_with_meurio
  end
end
