class Group < ActiveRecord::Base
  attr_accessible :name, :uid, :user, :synced_at
  validates :uid, :uniqueness => true, :allow_nil => true
  validates :name, :uniqueness => true
  has_and_belongs_to_many :users, :uniq => true
  has_many :groups_users
  before_create :create_mailee_list

  def self.sync_with_meurio
    page = 1
    group = Group.find_or_create_by_name("Meu Rio")
    time = Time.now
    members = Mico::Member.all(:page => page, :by_updated_at => group.synced_at)
    while members.any? do
      members.each do |member| 
        if !Rails.env.test? then puts "Syncing page ##{page} #{member['email']}" end
        group.users << User.find_or_create_by_meurio_hash(member)
      end
      members = Mico::Member.all(:page => page += 1, :by_updated_at => group.synced_at)
    end
    group.update_attribute :synced_at, time
  end

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
    self.groups_users.where(:synced_with_mailee => nil).each {|gu| gu.sync_with_mailee }
  end
  
  private
  def create_mailee_list
     self.mailee_id = (Mailee::List.find(:all).select{|l| l.name == "[Mr. Dash] #{self.name}"}.first || Mailee::List.create(:name => "[Mr. Dash] #{self.name}")).id
  end
end
