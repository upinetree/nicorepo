require 'spec_helper'

describe Nicorepo::Client do
  let(:client) { described_class.new }

  describe "#login" do
    context "with right account" do
      around do |example|
        VCR.use_cassette('login success') { example.run }
      end

      it "should be success" do
        expect(client.session).to be_an_instance_of String
      end
    end

    context "with wrong account" do
      around do |example|
        VCR.use_cassette('login failure') { example.run }
      end

      before do
        allow_any_instance_of(Netrc).to receive(:[]).and_return(Netrc::Entry.new('account@example.com', 'wrongpassword'))
      end

      it "should raise error" do
        expect { client.session }.to raise_error(Nicorepo::Request::Auth::LoginError)
      end
    end

    context "with no password" do
      before do
        allow_any_instance_of(Netrc).to receive(:[]).and_return(Netrc::Entry.new('account@example.com', nil))
      end

      it "should raise error" do
        expect { client.session }.to raise_error(Nicorepo::Client::AccountLackError)
      end
    end
  end

  describe "#all" do
    let(:report) { client.all(request_num) }

    around do |example|
      VCR.use_cassette('login success') { example.run }
    end

    context "with 5" do
      let(:request_num) { 1 }

      it "should return 1 log" do
        expect(report.size).to eq(request_num)
      end
    end

    context "with 50" do
      let(:request_num) { 50 }

      it "should return 50 logs" do
        expect(report.size).to eq(request_num)
      end
    end
  end

  describe "#videos" do
    let(:report) { client.videos(request_num, limit_page: limit_page) }
    let(:request_num) { 3 }

    around do |example|
      VCR.use_cassette('login success') { example.run }
    end

    context "with 3" do
      let(:limit_page) { nil }

      it "should return only video logs" do
        not_videos = report.raw.reject{ |h| h['topic'] == 'nicovideo.user.video.upload' }
        expect(not_videos.size).to eq(0)
      end

      it "should return 5 logs at the most" do
        expect(report.size).to be <= request_num
      end
    end

    context "with 10, limit_page = 1" do
      let(:limit_page) { 1 }

      it "should return only 1 page with 10 logs at the most" do
        expect(report.size).to be <= request_num
        expect(report.pages.size).to eq(1)
      end
    end
  end

  describe "#lives" do
    let(:report) { client.lives(request_num) }
    let(:request_num) { 3 }

    around do |example|
      VCR.use_cassette('login success') { example.run }
    end

    it "should return only live logs" do
      not_lives = report.raw.reject{ |h| h['topic'] =~ /live/ }
      expect(not_lives.size).to eq(0)
    end

    it "should return 5 logs at the most" do
      expect(report.size).to be <= request_num
    end
  end
end
