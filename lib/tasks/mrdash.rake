task :sync => :environment do
  Group.sync_with_meurio
  Group.sync_with_meurio_issues
  Group.all.each do |group|
    group.sync_with_provider
    group.sync_with_mailee
  end
end
