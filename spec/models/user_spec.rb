require 'spec_helper'

describe User do
  let(:page1_url){ "http://meurio.org.br/members.json?page=1&token=#{ENV["DASH_TOKEN"]}&by_updated_at=" }
  let(:page2_url){ "http://meurio.org.br/members.json?page=2&token=#{ENV["DASH_TOKEN"]}&by_updated_at=" }
  let(:page3_url){ "http://meurio.org.br/members.json?page=3&token=#{ENV["DASH_TOKEN"]}&by_updated_at=" }

  describe ".sync_with_mailee" do
    before { Mailee::List.stub(:find).and_return([Mailee::List.new(:name => "[Mr. Dash] Meu Rio")]) }

    context "when there is no list called [Mr. Dash] Meu Rio in Mailee" do
      it "should create this list" do
        Mailee::List.stub_chain(:find, :select).and_return([nil])
        Mailee::List.should_receive(:create).with(:name => "[Mr. Dash] Meu Rio")
        User.sync_with_mailee
      end
    end

    context "when it's the first sync ever" do
      before { Sync.stub_chain(:where, :order, :limit, :first).and_return(nil) }
      it "should call all users" do
        User.should_receive(:all).and_return([])
        User.sync_with_mailee
      end

      it "should sync all users" do
        User.stub(:all).and_return([mock_model(User), mock_model(User)])
        Mailee::Contact.should_receive(:create).exactly(2).times
        User.sync_with_mailee
      end
    end

    context "when it's not the first sync" do
      let(:time){ Time.now }
      before { Sync.stub_chain(:where, :order, :limit, :first).and_return(mock_model(Sync, :created_at => time)) }

      it "should call only changes since last sync" do
        User.should_receive(:where).with("updated_at >= ?", time).and_return([])
        User.sync_with_mailee
      end

      it "should sync only changes since last sync" do
        User.stub(:where).and_return([mock_model(User), mock_model(User)])
        Mailee::Contact.should_receive(:create).exactly(2).times
        User.sync_with_mailee
      end
    end
  end

  describe ".find_or_create_by_meurio_hash" do
    let(:options){{
      "first_name" => "Nicolas",
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
end
