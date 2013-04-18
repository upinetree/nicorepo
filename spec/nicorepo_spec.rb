require 'nicorepo'
require 'spec_helper'

describe Nicorepo do
  before do
    @nicorepo = Nicorepo.new
    @account = account
  end

  describe "#login" do
    context "with wrong account" do
      it "should be failed" do
        lambda{ @nicorepo.login('test', 'testpass') }.should raise_error(Nicorepo::LoginError)
      end
    end

    context "with right account" do
      it "should be success" do
        @nicorepo.login(@account[:mail], @account[:pass]).should be_true
      end
    end
  end

  after do
  end
end
