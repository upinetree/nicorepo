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

  describe "#num" do
    let(:conf) { Nicorepo::Cli::Config.new }

    context "without argument" do
      context "when 'general' num is NOT defined" do
        it "should return default num for fetching" do
          conf.stub!(:open).and_return({"mail" => "hoge", "pass" => "fuga"})
          conf.read

          default_num = Nicorepo::Cli::Config::Default::NUM
          conf.num.should eq(default_num)
        end
      end

      context "when 'general' num is defined" do
        it "should return defined num for fetching" do
          defined_num = 20
          conf.stub!(:open).and_return({"general" => {"num" => defined_num}, "mail" => "hoge", "pass" => "fuga"})
          conf.read

          conf.num.should eq(defined_num)
        end
      end
    end
  end

  describe "#nest" do
    let(:conf) { Nicorepo::Cli::Config.new }

    context "without argument" do
      it "should return default nest limit for fetching" do
        default_nest = Nicorepo::Cli::Config::Default::NEST
        conf.nest.should eq(default_nest)
      end
    end
  end

end

