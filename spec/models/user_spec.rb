require 'spec_helper'

describe User do
  describe ".sync_with_meurio" do
    before { stub_request(:get, "http://meurio.org.br/members.json?page=1&token=HelloWorld").to_return(:body => File.open("#{Rails.root}/features/support/mr_members1.json").read) }
    before { stub_request(:get, "http://meurio.org.br/members.json?page=2&token=HelloWorld").to_return(:body => File.open("#{Rails.root}/features/support/mr_members2.json").read) }
    before { stub_request(:get, "http://meurio.org.br/members.json?page=3&token=HelloWorld").to_return(:body => File.open("#{Rails.root}/features/support/mr_members3.json").read) }
    context "when there is 10 members in 2 pages" do
      it "should make a request to the first page" do
        User.sync_with_meurio
        WebMock.should have_requested(:get, "http://meurio.org.br/members.json").with(:query => {:token => ENV["DASH_TOKEN"], :page => 1})
      end

      it "should make a request to the second page" do
        User.sync_with_meurio
        WebMock.should have_requested(:get, "http://meurio.org.br/members.json").with(:query => {:token => ENV["DASH_TOKEN"], :page => 2})
      end

      it "should make a request to the third page" do
        User.sync_with_meurio
        WebMock.should have_requested(:get, "http://meurio.org.br/members.json").with(:query => {:token => ENV["DASH_TOKEN"], :page => 3})
      end

      it "should not make a request to the fourth page" do
        User.sync_with_meurio
        WebMock.should_not have_requested(:get, "http://meurio.org.br/members.json").with(:query => {:token => ENV["DASH_TOKEN"], :page => 4})
      end

      it "should create 10 users" do
        expect { User.sync_with_meurio }.to change{ User.count }.by(10)
      end
    end
  end
end
