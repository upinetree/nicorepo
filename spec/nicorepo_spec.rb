require 'nicorepo'
require 'spec_helper'

describe Nicorepo do
  before do
    @nicorepo = Nicorepo.new
    @account = account
  end

  describe "#login" do
    context "with wrong account" do
      it "should raise error" do
        lambda{ @nicorepo.login('test', 'testpass') }.should raise_error(Nicorepo::LoginError)
      end
    end

    context "with right account" do
      it "should be success" do
        @nicorepo.login(@account[:mail], @account[:pass])
        @nicorepo.agent.should be_true
      end
    end
  end

  describe "#all" do
    context "when fetch recent 20 logs" do
      it "should return 20 logs" do
        @nicorepo.all.size.should eq 20
      end
    end
  end

  after do
  end
end