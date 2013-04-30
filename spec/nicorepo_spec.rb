require 'nicorepo'
require 'spec_helper'

describe Nicorepo do
  before do
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
  end

  describe Nicorepo::Log do
    before do
      @log = @nicorepo.all[0]
    end
    
    it "should have the title" do
      puts @log.title
      @log.title.should be_true
    end

    it "should have the url" do
      puts @log.url
      @log.url.should be_true
    end

    after do
    end
  end

  after do
  end
end
