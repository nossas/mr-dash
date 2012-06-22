require 'spec_helper'

describe User do
  describe ".sync_with_meurio" do
    let(:page1_url){ "http://meurio.org.br/members.json?page=1&token=#{ENV["DASH_TOKEN"]}&by_updated_at=" }
    let(:page2_url){ "http://meurio.org.br/members.json?page=2&token=#{ENV["DASH_TOKEN"]}&by_updated_at=" }
    let(:page3_url){ "http://meurio.org.br/members.json?page=3&token=#{ENV["DASH_TOKEN"]}&by_updated_at=" }
    before { stub_request(:get, page1_url).to_return(:body => File.open("#{Rails.root}/features/support/mr_members1.json").read) }
    before { stub_request(:get, page2_url).to_return(:body => File.open("#{Rails.root}/features/support/mr_members2.json").read) }
    before { stub_request(:get, page3_url).to_return(:body => File.open("#{Rails.root}/features/support/mr_members3.json").read) }
    before { Sync.stub_chain(:where, :order, :limit, :first).and_return(mock_model(Sync)) }

    context "when there is 10 users in 2 pages" do
      it "should make a request to the first page" do
        User.sync_with_meurio
        WebMock.should have_requested(:get, "http://meurio.org.br/members.json").with(:query => {:token => ENV["DASH_TOKEN"], :page => 1, :by_updated_at => ""})
      end

      it "should make a request to the second page" do
        User.sync_with_meurio
        WebMock.should have_requested(:get, "http://meurio.org.br/members.json").with(:query => {:token => ENV["DASH_TOKEN"], :page => 2, :by_updated_at => ""})
      end

      it "should make a request to the third page" do
        User.sync_with_meurio
        WebMock.should have_requested(:get, "http://meurio.org.br/members.json").with(:query => {:token => ENV["DASH_TOKEN"], :page => 3, :by_updated_at => ""})
      end

      it "should not make a request to the fourth page" do
        User.sync_with_meurio
        WebMock.should_not have_requested(:get, "http://meurio.org.br/members.json").with(:query => {:token => ENV["DASH_TOKEN"], :page => 4, :by_updated_at => ""})
      end

      it "should create 10 users" do
        expect { User.sync_with_meurio }.to change{ User.count }.by(10)
      end
    end

    context "when the user already exists" do
      before { User.create :first_name => "Almir", :last_name => "Guineto", :email => "test@meurio.org.br" }
      it "should update this user" do
        User.sync_with_meurio
        User.find_by_email("test@meurio.org.br").name.should be_== "Joao Pesanha"
      end
    end
  end
end
