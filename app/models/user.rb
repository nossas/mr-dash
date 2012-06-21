class User < ActiveRecord::Base
  attr_accessible :avatar_url, :celular, :email, :first_name, :last_name, :registered_at
  validates :email, :uniqueness => true

  def self.sync_with_meurio
    page = 1
    last_sync = Sync.where(:name => "User.sync_with_meurio").order("created_at DESC").limit(1).first
    Sync.create :name => "User.sync_with_meurio"
    while true do
      members = JSON.parse(HTTParty.get("http://meurio.org.br/members.json", :query => {:token => ENV["DASH_TOKEN"], :page => page, :by_updated_at => last_sync ? last_sync.created_at : ""}).body)
      members.each do |member|
        user = User.find_by_email(member["email"])
        puts "Syncing page ##{page} #{member['email']}"
        if user
          user.update_attributes(
            :first_name => member["first_name"],
            :last_name => member["last_name"],
            :email => member["email"],
            :celular => member["celular"],
            :registered_at => member["created_at"],
            :avatar_url => member["image_url"]
          )
        else
          User.create(
            :first_name => member["first_name"],
            :last_name => member["last_name"],
            :email => member["email"],
            :celular => member["celular"],
            :registered_at => member["created_at"],
            :avatar_url => member["image_url"]
          )
        end
      end
      break if members.empty?
      page += 1
    end
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end
end
