require 'spec_helper'

describe Nicorepo do
  before(:all) do
    mail, pass = Netrc.read["nicovideo.jp"]
    @nicorepo = Nicorepo.new
    @nicorepo.login(mail, pass)
  end

  describe "#login" do
    context "with right account" do
      it "should be success" do
        @nicorepo.agent.should be_true
      end
    end

    context "with wrong account" do
      it "should raise error" do
        repo = Nicorepo.new
        expect{ repo.login('test', 'testpass') }.to raise_error(Nicorepo::LoginError)
      end
    end
  end

  describe "#all" do
    context "with 5" do
      it "should return 5 reports" do
        @nicorepo.all(5).should have(5).reports
      end
    end

    context "with 50" do
      it "should return 50 reports" do
        @nicorepo.all(50).should have(50).reports
      end
    end
  end

  describe "#videos" do
    context "with req_num = 5, page_nest_max = 3" do
      it "should return only video reports" do
        videos = @nicorepo.videos
        not_videos = videos.reject{ |v| v.kind =~ /video/ }
        not_videos.size.should eq 0
      end

      it "should return 5 reports at the most" do
        @nicorepo.videos(5, 3).should have_at_most(5).reports
      end
    end
  end

  describe "#lives" do
    it "should return only live reports" do
      lives = @nicorepo.lives
      not_lives = lives.reject{ |l| l.kind =~ /live/ }
      not_lives.size.should eq 0
    end
  end
end

