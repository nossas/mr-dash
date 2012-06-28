task :sync => :environment do
  puts "Syncing with Meu Rio..."
  User.sync_with_meurio
  puts "Syncing with Mailee..."
  User.sync_with_mailee
  puts "Syncing Meu Rio issues..."
  Group.sync_with_meurio_issues
  puts "Syncing groups..."
  Group.all.each do |group|
    group.sync_with_meurio_members
  end
end
