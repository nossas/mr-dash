require 'spec_helper'

describe User do
  let(:mr_members_file1){ File.open("#{Rails.root}/features/support/mr_members1.json").read }
  let(:mr_members_file2){ File.open("#{Rails.root}/features/support/mr_members2.json").read }
  let(:mr_members_file3){ File.open("#{Rails.root}/features/support/mr_members3.json").read }
  let(:page1_url){ "http://meurio.org.br/members.json?page=1&token=#{ENV["DASH_TOKEN"]}&by_updated_at=" }
  let(:page2_url){ "http://meurio.org.br/members.json?page=2&token=#{ENV["DASH_TOKEN"]}&by_updated_at=" }
  let(:page3_url){ "http://meurio.org.br/members.json?page=3&token=#{ENV["DASH_TOKEN"]}&by_updated_at=" }

  describe ".get_meurio_members" do
    before { stub_request(:get, page1_url).to_return(:body => mr_members_file1) }
    before { stub_request(:get, page2_url).to_return(:body => mr_members_file2) }
    before { stub_request(:get, page3_url).to_return(:body => mr_members_file3) }

    it "should make a request to Meu Rio" do
      User.get_meurio_members(1, nil).should be_== JSON.parse(mr_members_file1)
      User.get_meurio_members(2, nil).should be_== JSON.parse(mr_members_file2)
      User.get_meurio_members(3, nil).should be_== JSON.parse(mr_members_file3)
    end
  end

  describe ".sync_with_meurio" do
    before { Sync.stub(:create) }

    context "when it's the first sync ever" do
      before { Sync.stub_chain(:where, :order, :limit, :first).and_return(nil) }

      it "should call get_meurio_members with no by_updated_at argument" do
        User.should_receive(:get_meurio_members).with(1, nil).and_return(JSON.parse(mr_members_file3))
        User.sync_with_meurio
      end
    end

    context "when it's not the first sync" do
      let(:time){ Time.now }
      before { Sync.stub_chain(:where, :order, :limit, :first).and_return(mock_model(Sync, :created_at => time)) }

      it "should call get_meurio_members with by_updated_at argument" do
        User.should_receive(:get_meurio_members).with(1, time).and_return(JSON.parse(mr_members_file3))
        User.sync_with_meurio
      end
    end

    context "when there is 10 users in 2 pages" do
      before { Sync.stub_chain(:where, :order, :limit, :first).and_return(nil) }
      before { User.stub(:get_meurio_members).with(1, nil).and_return(JSON.parse(mr_members_file1)) }
      before { User.stub(:get_meurio_members).with(2, nil).and_return(JSON.parse(mr_members_file2)) }
      before { User.stub(:get_meurio_members).with(3, nil).and_return(JSON.parse(mr_members_file3)) }

      context "when all users are new" do
        it "should create 10 users" do
          expect { User.sync_with_meurio }.to change{ User.count }.by(10)
        end
      end

      context "when one of the users already exists" do
        before { User.create :first_name => "Almir", :last_name => "Guineto", :email => "test@meurio.org.br" }
        it "should create 9 users" do
          expect { User.sync_with_meurio }.to change{ User.count }.by(9)
        end
        it "should update the existing user" do
          User.sync_with_meurio
          User.find_by_email("test@meurio.org.br").first_name.should be_== "Joao"
        end
      end
    end
  end

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
end
