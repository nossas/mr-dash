class User < ActiveRecord::Base
  attr_accessible :avatar_url, :celular, :email, :first_name, :last_name, :registered_at
  validates :email, :uniqueness => true

  def self.sync_with_mailee
    list = Mailee::List.find(:all).select{|l| l.name == "[Mr. Dash] Meu Rio"}.first || Mailee::List.create(:name => "[Mr. Dash] Meu Rio")
    last_sync = Sync.where(:name => "User.sync_with_mailee").order("created_at DESC").limit(1).first
    Sync.create :name => "User.sync_with_mailee"
    users = last_sync ? User.where("updated_at >= ?", last_sync.created_at) : User.all
    users.each do |user|
      if !Rails.env.test? then puts "Syncing #{user.email}" end
      Mailee::Contact.create(:email => user.email, :name => user.first_name, :list_ids => [list.id])
    end
  end

  def self.find_or_create_by_meurio_hash options
    User.find_or_create_by_email(
      options["email"], 
      :first_name => options["first_name"],
      :last_name => options["last_name"],
      :email => options["email"],
      :celular => options["celular"],
      :registered_at => options["created_at"],
      :avatar_url => options["image_url"]
    )
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end
end
