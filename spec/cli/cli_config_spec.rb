require 'spec_helper'

describe Nicorepo::Cli::Config do
  let(:conf) { Nicorepo::Cli::Config.new }

  before do
    Nicorepo::Cli::Config.any_instance.stub(:load_config).and_return(config_values)
  end

  describe "#num" do
    context "with 'all' command" do
      context "'all' num is NOT defined" do
        context "'general' num is NOT defined" do
          let(:config_values) { {} }

          it "should return default num" do
            default_num = conf.send(:defaults)["num"]["general"]
            conf.num("all").should eq(default_num)
          end
        end

        context "'general' num is defined" do
          let(:general_num) { 20 }
          let(:config_values) { { "num" => { "general" => general_num } } }

          it "should return defined 'general' num" do
            conf.num("all").should eq(general_num)
          end
        end
      end

      context "'all' num is defined" do
        context "'general' num is NOT defined" do
          let(:all_num) { 20 }
          let(:config_values) { { "num" => { "all" => all_num } } }

          it "should return defined 'all' num" do
            conf.num("all").should eq(all_num)
          end
        end

        context "'general' num is defined" do
          let(:all_num) { 20 }
          let(:general_num) { 15 }
          let(:config_values) { { "num" => { "all" => all_num, "general" => general_num } } }

          it "should return defined 'all' num" do
            conf.num("all").should eq(all_num)
          end
        end
      end
    end
  end

  describe "#nest" do
    context "with 'all' command" do
      context "'all' nest is defined" do
        context "'general' nest is defined" do
          let(:all_nest) { 10 }
          let(:general_nest) { 5 }
          let(:config_values) { { "nest" => { "all" => all_nest, "general" => general_nest } } }

          it "should return defined 'all' nest" do
            conf.nest("all").should eq(all_nest)
          end
        end
      end
    end
  end
end

