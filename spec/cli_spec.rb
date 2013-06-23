require 'nicorepo'
require 'spec_helper'

describe Nicorepo::Cli do
  before(:all) do
    @old_stderr = $stderr
    $stderr = StringIO.new
  end

  describe "#run" do
    context "when login failed" do
      it "should exit with error massage" do
        cli = Nicorepo::Cli.new
        begin
          cli.stub!(:account).and_return({mail: 'hoge', pass: 'piyo'})
          cli.run([ 'i' ])
        rescue SystemExit => se
          se.status.should eq 1 
          $stderr.string.should match /invalid mail or pass/
        end
      end
    end

    context "with command 'i'" do
      it "should exec interactive mode" do
        argv = [ 'i' ]
        cli = Nicorepo::Cli.new
        cli.should_receive(:interactive_run)
        cli.run(argv)
      end
    end

    context "with command 'lives'" do
      it "should recieve logs of live" do
        argv = [ 'lives', '5', '3' ]
        Nicorepo.any_instance.should_receive(:lives).with(5, 3).and_return([Nicorepo::Log.new])
        cli = Nicorepo::Cli.new
        cli.run(argv)
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
    context "when config.txt not found" do
      it "should exit with error massage" do
        cli  = Nicorepo::Cli.new
        begin
          cli.stub!(:open).and_return(nil)
          cli.account
        rescue SystemExit => se
          se.status.should eq 1 
          $stderr.string.should match /config read error/
        end
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
