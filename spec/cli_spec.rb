require 'nicorepo'
require 'spec_helper'

describe Nicorepo::Cli do
  before(:all) do
    @old_stderr = $stderr
    $stderr = StringIO.new
  end

  describe "#run" do

    let(:cli) { Nicorepo::Cli.new }

    context "when login failed" do
      it "should exit with error massage" do
        begin
          Nicorepo.any_instance.stub(:login).and_raise(StandardError)
          cli.stub(:account).and_return({mail: "hoge@fuga.piyo", pass: "foobar"})
          cli.run([ 'i' ])
        rescue SystemExit => se
          se.status.should eq 1 
          $stderr.string.should match /invalid mail or pass/
        end
      end
    end

    context "when login succeed" do

      before(:each) do
        cli.stub(:login)
      end

      context "with command 'i'" do
        it "should exec interactive mode" do
          cli.should_receive(:interactive_run)
          cli.run([ 'i' ])
        end
      end

      context "with command 'lives'" do
        it "should recieve logs of live" do
          Nicorepo.any_instance.should_receive(:lives).and_return([Nicorepo::Log.new])
          cli.run([ 'lives' ])
        end
      end
    end
  end

  describe "#interactive_run" do
    context "when entered 'exit'" do
      it "should return true" do
        cli = Nicorepo::Cli.new
        Readline.stub!(:readline) { 'exit' }
        cli.interactive_run.should be_true
      end
    end
  end

  describe "#account" do

    let(:cli) { Nicorepo::Cli.new }

    context "when config.yaml not found" do
      it "should exit with error massage" do
        cli.stub!(:open).and_raise(StandardError)
        expect{cli.account}.to raise_error(Nicorepo::Cli::AccountError)
      end
    end

    context "when config.yaml does not have 'mail'" do
      it "should raise error" do
        cli.stub!(:open).and_return({"pass" => "hoge"})
        expect{cli.account}.to raise_error(Nicorepo::Cli::AccountError)
      end
    end

    context "when config.yaml does not have 'pass'" do
      it "should raise error" do
        cli.stub!(:open).and_return({"mail" => "hoge"})
        expect{cli.account}.to raise_error(Nicorepo::Cli::AccountError)
      end
    end

    context "when config.yaml has 'mail' and 'pass'" do
      it "should return the hash 'mail' and 'pass'" do
        cli.stub!(:open).and_return({"mail" => "hoge", "pass" => "fuga"})
        cli.account.should include(:mail => "hoge", :pass => "fuga")
      end
    end
  end

  describe "#open_url" do
    context "with 1" do
      before do
        @cli = Nicorepo::Cli.new
        @logs = [ Nicorepo::Log.new ]
      end

      it "should succeed to open url in browser with first log's url" do
        @logs.first.url = 'http://www.nicovideo.jp'
        expect{ @cli.open_url(@logs, 1, {dry_run: true}) }.to be_true
      end

      it "should raise error when url is nil" do
        @logs.first.url = nil
        expect{ @cli.open_url(@logs, 1, {dry_run: true}) }.to raise_error
      end

      it "should raise error when url is wrongs" do
        @logs.first.url = 'hoge://piyo'
        expect{ @cli.open_url(@logs, 1, {dry_run: true}) }.to raise_error
      end
    end
  end

  after(:all) do
    $stderr = @old_stderr
  end
end
