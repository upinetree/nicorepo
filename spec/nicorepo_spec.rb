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
        expect(@nicorepo.agent).to be_truthy
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
        expect(@nicorepo.all(5).size).to eq(5)
      end
    end

    context "with 50" do
      it "should return 50 reports" do
        expect(@nicorepo.all(50).size).to eq(50)
      end
    end

    context "when an error occured" do
      before do
        allow_any_instance_of(Nicorepo::Parser).to receive(:parse_title).and_raise("SomeError")
      end

      it "should return erorr reports" do
        error_report = @nicorepo.all(1).first
        expect(error_report.title).to eq("An exception occured: SomeError")
      end
    end
  end

  describe "#videos" do
    context "with request_num = 5, limit_page = 3" do
      it "should return only video reports" do
        videos = @nicorepo.videos
        not_videos = videos.reject{ |v| v.kind =~ /video/ }
        expect(not_videos.size).to eq(0)
      end

      it "should return 5 reports at the most" do
        expect(@nicorepo.videos(5, 3).size).to be <= 5
      end
    end
  end

  describe "#lives" do
    it "should return only live reports" do
      lives = @nicorepo.lives
      not_lives = lives.reject{ |l| l.kind =~ /live/ }
      expect(not_lives.size).to eq(0)
    end
  end
end

