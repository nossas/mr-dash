class User < ActiveRecord::Base
  attr_accessible :avatar_url, :celular, :email, :first_name, :last_name, :registered_at
  validates :email, :uniqueness => true

  def self.sync_with_meurio
    page = 1
    while true do
      members = JSON.parse(HTTParty.get("http://meurio.org.br/members.json", :query => {:token => ENV["DASH_TOKEN"], :page => page}).body)
      members.each do |member|
        User.create(
          :first_name => member["first_name"],
          :last_name => member["last_name"],
          :email => member["email"],
          :celular => member["celular"],
          :registered_at => member["created_at"],
          :avatar_url => member["image_url"]
        )
      end
      break if members.empty?
      page += 1
    end
  end
end
