require 'spec_helper'

describe Nicorepo::Cli::Config do

  describe "#read" do

    let(:conf) { Nicorepo::Cli::Config.new }

    context "when config.yaml not found" do
      it "should raise ReadError" do
        conf.stub!(:open).and_raise(StandardError)
        expect{conf.read}.to raise_error(Nicorepo::Cli::Config::ReadError)
      end
    end

    context "when config.yaml does not have 'mail'" do
      it "should raise error" do
        conf.stub!(:open).and_return({"pass" => "hoge"})
        expect{conf.read}.to raise_error(Nicorepo::Cli::Config::AccountError)
      end
    end

    context "when config.yaml does not have 'pass'" do
      it "should raise error" do
        conf.stub!(:open).and_return({"mail" => "hoge"})
        expect{conf.read}.to raise_error(Nicorepo::Cli::Config::AccountError)
      end
    end

  end

  describe "#account" do

    let(:conf) { Nicorepo::Cli::Config.new }

    context "when config.yaml has 'mail' and 'pass'" do
      it "should return the hash 'mail' and 'pass'" do
        conf.stub!(:open).and_return({"mail" => "hoge", "pass" => "fuga"})
        conf.read
        conf.account.should include(:mail => "hoge", :pass => "fuga")
      end
    end
  end

end

