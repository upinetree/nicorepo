require 'spec_helper'

describe Nicorepo::Cli::Config do

  include CliHelper

  describe "#read" do
    let(:conf) { Nicorepo::Cli::Config.new }

    context "when config.yaml not found" do
      it "should raise ReadError" do
        conf.stub!(:open).and_raise(StandardError)
        expect{conf.read}.to raise_error(Nicorepo::Cli::Config::ReadError)
      end
    end
  end

  describe "#num" do
    let(:conf) { Nicorepo::Cli::Config.new }

    context "with 'all' command" do
      context "when 'all' num is NOT defined" do
        context "and 'general' num is NOT defined" do
          it "should return default num" do
            conf_init(conf, {"mail" => "hoge", "pass" => "fuga"})

            default_num = Nicorepo::Cli::Config::Default::NUM
            conf.num("all").should eq(default_num)
          end
        end

        context "and 'general' num is defined" do
          it "should return defined 'general' num" do
            defined_num = 20
            conf_init(conf, {"general" => {"num" => defined_num}, "mail" => "hoge", "pass" => "fuga"})

            conf.num("all").should eq(defined_num)
          end
        end
      end

      context "when 'all' num is defined" do
        context "and 'general' num is NOT defined" do
          it "should return defined 'all' num" do
            defined_num = 20
            conf_init(conf, {"all" => {"num" => defined_num}, "mail" => "hoge", "pass" => "fuga"})

            conf.num("all").should eq(defined_num)
          end
        end

        context "and 'general' num is defined" do
          it "should return defined 'all' num" do
            all_num = 20
            general_num = 15
            conf_init(conf, {"general" => {"num" => general_num}, "all" => {"num" => all_num}, "mail" => "hoge", "pass" => "fuga"})

            conf.num("all").should eq(all_num)
          end
        end
      end
    end
  end

  describe "#nest" do
    let(:conf) { Nicorepo::Cli::Config.new }

    context "with 'all' command" do
      context "when 'all' nest is NOT defined" do
        context "and 'general' nest is NOT defined" do
          it "should return default nest" do
            conf_init(conf, {"mail" => "hoge", "pass" => "fuga"})

            default_nest = Nicorepo::Cli::Config::Default::NEST
            conf.nest("all").should eq(default_nest)
          end
        end

        context "and 'general' nest is defined" do
          it "should return defined 'general' nest" do
            defined_nest = 10
            conf_init(conf, {"general" => {"nest" => defined_nest}, "mail" => "hoge", "pass" => "fuga"})

            conf.nest("all").should eq(defined_nest)
          end
        end
      end

      context "when 'all' nest is defined" do
        context "and 'general' nest is NOT defined" do
          it "should return defined 'all' nest" do
            defined_nest = 10
            conf_init(conf, {"all" => {"nest" => defined_nest}, "mail" => "hoge", "pass" => "fuga"})

            conf.nest("all").should eq(defined_nest)
          end
        end

        context "and 'general' nest is defined" do
          it "should return defined 'all' nest" do
            all_nest = 10
            general_nest = 5
            conf_init(conf, {"general" => {"nest" => general_nest}, "all" => {"nest" => all_nest}, "mail" => "hoge", "pass" => "fuga"})

            conf.nest("all").should eq(all_nest)
          end
        end
      end
    end
  end
end

