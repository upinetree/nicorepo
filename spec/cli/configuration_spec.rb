require 'spec_helper'
require 'nicorepo/cli'

describe Nicorepo::Cli::Configuration do
  let(:conf) { Nicorepo::Cli::Configuration.new }

  before do
    allow_any_instance_of(Nicorepo::Cli::Configuration).to receive(:load_config).and_return(config_values)
  end

  describe "#request_num" do
    context "with 'all' command" do
      context "'all' request_num is NOT defined" do
        context "'general' request_num is NOT defined" do
          let(:config_values) { {} }

          it "should return default request_num" do
            default_request_num = conf.send(:defaults)["request_num"]["general"]
            expect(conf.request_num("all")).to eq(default_request_num)
          end
        end

        context "'general' request_num is defined" do
          let(:general_request_num) { 20 }
          let(:config_values) { { "request_num" => { "general" => general_request_num } } }

          it "should return defined 'general' request_num" do
            expect(conf.request_num("all")).to eq(general_request_num)
          end
        end
      end

      context "'all' request_num is defined" do
        context "'general' request_num is NOT defined" do
          let(:all_request_num) { 20 }
          let(:config_values) { { "request_num" => { "all" => all_request_num } } }

          it "should return defined 'all' request_num" do
            expect(conf.request_num("all")).to eq(all_request_num)
          end
        end

        context "'general' request_num is defined" do
          let(:all_request_num) { 20 }
          let(:general_request_num) { 15 }
          let(:config_values) { { "request_num" => { "all" => all_request_num, "general" => general_request_num } } }

          it "should return defined 'all' request_num" do
            expect(conf.request_num("all")).to eq(all_request_num)
          end
        end
      end
    end
  end

  describe "#limit_page" do
    context "with 'all' command" do
      context "'all' limit_page is defined" do
        context "'general' limit_page is defined" do
          let(:all_limit_page) { 10 }
          let(:general_limit_page) { 5 }
          let(:config_values) { { "limit_page" => { "all" => all_limit_page, "general" => general_limit_page } } }

          it "should return defined 'all' limit_page" do
            expect(conf.limit_page("all")).to eq(all_limit_page)
          end
        end
      end
    end
  end
end

