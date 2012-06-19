class User < ActiveRecord::Base
  attr_accessible :avatar_url, :celular, :email, :first_name, :last_name, :registered_at
end
