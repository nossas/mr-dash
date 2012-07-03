class User < ActiveRecord::Base
  attr_accessible :avatar_url, :celular, :email, :first_name, :last_name, :registered_at
  validates :email, :uniqueness => true
  has_and_belongs_to_many :groups, :uniq => true

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

  def self.find_or_create_by_voc_hash options
    User.find_or_create_by_email(
      options["email"], 
      :first_name => options["name"],
      :email => options["email"],
      :registered_at => options["created_at"],
      :avatar_url => options["picture"]
    )
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end
end
