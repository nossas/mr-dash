desc "Sinchronyze users from meurio into MrDash database"
task :sync_with_meurio => :environment do
  puts "Syncing with Meu Rio..."
  User.sync_with_meurio
end
