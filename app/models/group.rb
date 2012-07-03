class Group < ActiveRecord::Base
  attr_accessible :name, :uid, :user, :synced_at, :provider
  validates_uniqueness_of :uid, :scope => :provider_id, :allow_nil => true
  validates :name, :uniqueness => true
  has_and_belongs_to_many :users, :uniq => true
  has_many :groups_users
  belongs_to :provider
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

  def sync_with_provider
    if self.provider
      if self.provider.name == "Meu Rio"
        self.sync_with_meurio
      elsif self.provider.name == "VoC"
        self.sync_with_voc
      end
    end
  end

  def sync_with_mailee
    self.groups_users.where(:synced_with_mailee => nil).each {|gu| gu.sync_with_mailee }
  end

  protected 
  def sync_with_meurio
    time = Time.now
    signatures = Mico::PetitionSignature.find_all_by_issue_id(self.uid, :by_updated_at => self.synced_at, :page => page = 1)
    while signatures.any? do
      signatures.each {|signature| self.users << User.find_or_create_by_meurio_hash(signature["member"])}
      signatures = Mico::PetitionSignature.find_all_by_issue_id(self.uid, :by_updated_at => self.synced_at, :page => page += 1)
    end
    self.update_attribute :synced_at, time
  end

  def sync_with_voc
    time = Time.now
    questions = Arara::Question.find_all_by_category_id(self.uid, :by_updated_at => self.synced_at, :page => page = 1)
    while questions.any? do
      questions.each {|question| self.users << User.find_or_create_by_voc_hash(question["user_info"])}
      questions = Arara::Question.find_all_by_category_id(self.uid, :by_updated_at => self.synced_at, :page => page += 1)
    end
    self.update_attribute :synced_at, time
  end

  private
  def create_mailee_list
    mailee_name = self.provider ? "[Mr. Dash] [#{self.provider.name}] #{self.name}" : "[Mr. Dash] #{self.name}"
    self.mailee_id = (Mailee::List.find(:all).select{|l| l.name == mailee_name}.first || Mailee::List.create(:name => mailee_name)).id
  end
end
