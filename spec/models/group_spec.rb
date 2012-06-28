require 'spec_helper'

describe Group do
  describe ".sync_with_meurio_issues" do
    before { Mico::Issue.stub(:all).and_return([{"id" => 1, "name" => "Etica na Administracao Publica"}, {"id" => 2, "name" => "Poder e autoridade em favelas com UPP"}]) }
    it "should create a group for each campaign" do
      expect { Group.sync_with_meurio_issues }.to change{ Group.count }.by(2)
    end
  end

  describe "#sync_with_meurio_members" do
    let(:time){ Time.parse("2012-06-28 14:58:34 -0300") }
    let(:user){ mock_model(User) }
    let(:member1){ {"member" => {"email" => "abcd@meurio.org.br"}} }
    let(:member2){ {"member" => {"email" => "abcd2@meurio.org.br"}} }
    let(:member3){ {"member" => {"email" => "abcd3@meurio.org.br"}} }
    let(:member4){ {"member" => {"email" => "abcd4@meurio.org.br"}} }
    before { subject.stub(:uid).and_return(1) }
    before { Mico::PetitionSignature.stub(:find_all_by_issue_id).with(1, :by_updated_at => subject.synced_at, :page => 1).and_return([member1, member2]) }
    before { Mico::PetitionSignature.stub(:find_all_by_issue_id).with(1, :by_updated_at => subject.synced_at, :page => 2).and_return([]) }
    before { Time.stub(:now).and_return(time) }

    it "should find or create each member of each signature" do
      User.should_receive(:find_or_create_by_meurio_hash).twice.and_return(user)
      subject.sync_with_meurio_members
    end
    
    it "should create a relation between the group and the user" do
      User.stub(:find_or_create_by_meurio_hash).and_return(user)
      subject.users.should_receive(:<<).with(user).twice
      subject.sync_with_meurio_members
    end

    it "should update the synced_at group's attribute" do
      subject.should_receive(:update_attribute).with(:synced_at, time)
      subject.sync_with_meurio_members
    end

    context "when the group have been synced before" do
      before { subject.stub(:synced_at).and_return(time) }

      it "should filter signatures since last sync" do
        Mico::PetitionSignature.should_receive(:find_all_by_issue_id).with(1, :by_updated_at => time, :page => 1)
        subject.sync_with_meurio_members
      end
    end

    context "when there is two pages of signatures" do
      before { Mico::PetitionSignature.stub(:find_all_by_issue_id).with(1, :by_updated_at => subject.synced_at, :page => 2).and_return([member3, member4]) }
      before { Mico::PetitionSignature.stub(:find_all_by_issue_id).with(1, :by_updated_at => subject.synced_at, :page => 3).and_return([]) }
      it "should find or create each member of each signature of each page" do
        User.should_receive(:find_or_create_by_meurio_hash).exactly(4).times.and_return(user)
        subject.sync_with_meurio_members
      end
    end
  end
end
