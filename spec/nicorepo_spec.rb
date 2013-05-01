require 'nicorepo'
require 'spec_helper'

describe Nicorepo do
  before(:all) do
    @nicorepo = Nicorepo.new
    @account = account

    @nicorepo.login(@account[:mail], @account[:pass])
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
      it "should return 20 logs" do
        @nicorepo.all.should have(20).logs
      end
    end

    context "with 5" do
      it "should return 5 logs" do
        @nicorepo.all(5).should have(5).logs
      end
    end

    context "with 30" do
      it "should return 30 logs" do
        @nicorepo.all(30).should have(30).logs
      end
    end

    context "with 50" do
      it "should return 50 logs" do
        @nicorepo.all(50).should have(50).logs
      end
    end
  end

  describe "#videos" do
    context "when videos are existing on timeline" do
      it "should return only video logs" do
        videos = @nicorepo.videos
        rejected = videos.reject{ |v| v.kind =~ /video/ }
        rejected.size.should eq 0
      end
    end

    context "without arguments" do
      it "should return 3 logs at the most" do
        @nicorepo.videos.should have_at_most(3).logs
      end
    end

    context "with req_num = 5, page_nest_max = 3" do
      it "should return 5 logs at the most" do
        @nicorepo.videos(5, 3).should have_at_most(5).logs
      end
    end
  end

  describe Nicorepo::Log do
    before(:all) do
      @log = @nicorepo.all.first
      p @log
    end
    
    it "should have the body" do
      @log.body.should be_true
    end

    it "should have the target" do
      @log.target.should be_true
    end

    it "should have the url" do
      @log.url.should be_true
    end

    it "should have the author" do
      @log.author.should be_true
    end

    it "should have the log-kind" do
      @log.kind.should be_true
    end

    after do
    end
  end

  after do
  end
end
