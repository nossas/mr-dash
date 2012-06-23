task :sync => :environment do
  puts "Syncing with Meu Rio..."
  User.sync_with_meurio
  puts "Syncing with Mailee..."
  User.sync_with_mailee
end
