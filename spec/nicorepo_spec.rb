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
        # @nicorepo.all.size.should eq 20
        @nicorepo.all.should have(20).logs
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

    after do
    end
  end

  after do
  end
end
