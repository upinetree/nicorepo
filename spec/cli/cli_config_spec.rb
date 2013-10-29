require 'nicorepo'
require 'spec_helper'

describe Nicorepo::Cli::Config do

  describe "#account" do

    let(:conf) { Nicorepo::Cli::Config.new }

    context "when config.yaml not found" do
      it "should exit with error massage" do
        conf.stub!(:open).and_raise(StandardError)
        expect{conf.account}.to raise_error(Nicorepo::Cli::AccountError)
      end
    end

    context "when config.yaml does not have 'mail'" do
      it "should raise error" do
        conf.stub!(:open).and_return({"pass" => "hoge"})
        expect{conf.account}.to raise_error(Nicorepo::Cli::AccountError)
      end
    end

    context "when config.yaml does not have 'pass'" do
      it "should raise error" do
        conf.stub!(:open).and_return({"mail" => "hoge"})
        expect{conf.account}.to raise_error(Nicorepo::Cli::AccountError)
      end
    end

    context "when config.yaml has 'mail' and 'pass'" do
      it "should return the hash 'mail' and 'pass'" do
        conf.stub!(:open).and_return({"mail" => "hoge", "pass" => "fuga"})
        conf.account.should include(:mail => "hoge", :pass => "fuga")
      end
    end
  end

end

