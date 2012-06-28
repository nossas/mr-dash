class Group < ActiveRecord::Base
  attr_accessible :name, :uid, :user, :synced_at
  validates :uid, :uniqueness => true
  has_and_belongs_to_many :users

  def self.sync_with_meurio_issues
    Mico::Issue.all.each { |campaign| Group.find_or_create_by_uid(campaign["id"].to_s, :name => campaign["name"]) }
  end

  def sync_with_meurio_members
    page = 1
    time = Time.now
    signatures = Mico::PetitionSignature.find_all_by_issue_id(self.uid, :by_updated_at => self.synced_at, :page => page)
    while signatures.any? do
      signatures.each do |signature|
        if !Rails.env.test? then puts "Syncing page ##{page} #{signature['member']['email']}" end
        self.users << User.find_or_create_by_meurio_hash(signature["member"])
      end
      signatures = Mico::PetitionSignature.find_all_by_issue_id(self.uid, :by_updated_at => self.synced_at, :page => page += 1)
    end
    self.update_attribute :synced_at, time
  end

  def sync_with_mailee
  end
end
