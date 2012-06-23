class User < ActiveRecord::Base
  attr_accessible :avatar_url, :celular, :email, :first_name, :last_name, :registered_at
  validates :email, :uniqueness => true

  def self.sync_with_meurio
    last_sync = Sync.where(:name => "User.sync_with_meurio").order("created_at DESC").limit(1).first
    Sync.create :name => "User.sync_with_meurio"
    members = User.get_meurio_members(page = 1, last_sync ? last_sync.created_at : nil)
    while members.any? do
      members.each do |member|
        if !Rails.env.test? then puts "Syncing page ##{page} #{member['email']}" end
        options = {
          :first_name => member["first_name"],
          :last_name => member["last_name"],
          :email => member["email"],
          :celular => member["celular"],
          :registered_at => member["created_at"],
          :avatar_url => member["image_url"]
        }
        if user = User.find_by_email(options[:email])
          user.update_attributes(options)
        else
          User.create(options)
        end
      end
      members = User.get_meurio_members(page += 1, last_sync ? last_sync.created_at : nil)
    end
  end

  def self.get_meurio_members page = 1, by_updated_at = nil
    JSON.parse(HTTParty.get("http://meurio.org.br/members.json", :query => {:token => ENV["DASH_TOKEN"], :page => page, :by_updated_at => by_updated_at}).body)
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end
end
