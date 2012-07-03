require 'spec_helper'

describe User do
  describe ".find_or_create_by_meurio_hash" do
    let(:options){{"first_name" => "Nicolas",
                   "last_name" => "Iensen",
                   "email" => "abcd@meurio.org.br",
                   "celular" => "21 99291222",
                   "created_at" => nil,
                   "image_url" => nil
    }}
    it "should find or create an user based on Meu Rio hash" do
      User.should_receive(:find_or_create_by_email).with(
        options["email"], 
        :first_name => options["first_name"],
        :last_name => options["last_name"],
        :email => options["email"],
        :celular => options["celular"],
        :registered_at => options["created_at"],
        :avatar_url => options["image_url"]
      )
      User.find_or_create_by_meurio_hash(options)
    end
  end

  describe ".find_or_create_by_voc_hash" do
    let(:options){{"created_at" => "2012-06-09T16:27:59-03:00",
                   "email" => "abcd@meurio.org.br",
                   "id" => 28,
                   "name" => "Carlos Oliveira",
                   "picture" => "http://graph.facebook.com/1199131415/picture?type=square",
                   "updated_at" => "2012-06-09T16:27:59-03:00"
    }}
    it "should find or create an user based on VoC hash" do
      User.should_receive(:find_or_create_by_email).with(
        options["email"],
        :first_name => options["name"],
        :email => options["email"],
        :registered_at => options["created_at"],
        :avatar_url => options["picture"]
      )
      User.find_or_create_by_voc_hash(options)
    end
  end
end
