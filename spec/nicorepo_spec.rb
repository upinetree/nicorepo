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
        lambda{ repo.login('test', 'testpass') }.should raise_error(Nicorepo::LoginError)
      end
    end
  end

  describe "#all" do
    context "without arguments" do
      it "should return 20 reports" do
        @nicorepo.all.should have(20).reports
      end
    end

    context "with 5" do
      it "should return 5 reports" do
        @nicorepo.all(5).should have(5).reports
      end
    end

    context "with 30" do
      it "should return 30 reports" do
        @nicorepo.all(30).should have(30).reports
      end
    end

    context "with 50" do
      it "should return 50 reports" do
        @nicorepo.all(50).should have(50).reports
      end
    end
  end

  describe "#videos" do
    context "without arguments" do
      it "should return 3 reports at the most" do
        @nicorepo.videos.should have_at_most(3).reports
      end

      it "should return only video reports" do
        videos = @nicorepo.videos
        except_video = videos.reject{ |v| v.kind =~ /video/ }
        except_video.size.should eq 0
      end
    end

    context "with req_num = 5, page_nest_max = 3" do
      it "should return 5 reports at the most" do
        @nicorepo.videos(5, 3).should have_at_most(5).reports
      end
    end
  end

  describe "#lives" do
    it "should return only live reports" do
      lives = @nicorepo.lives
      except_live = lives.reject{ |l| l.kind =~ /live/ }
      except_live.size.should eq 0
    end
  end
end

