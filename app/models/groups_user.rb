class GroupsUser < ActiveRecord::Base
  attr_accessible :synced_with_mailee
  belongs_to :user

  def sync_with_mailee
    if !Rails.env.test? then puts "Syncing #{user.email}" end
    begin
      Mailee::Contact.create(:email => user.email, :name => user.first_name, :list_ids => user.groups.map{|g| g.mailee_id})
      self.update_attribute :synced_with_mailee, true
    rescue
      puts "Error syncing #{user.email}"
    end
  end
end
