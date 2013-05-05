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
          cli.run([ '-i' ])
        rescue SystemExit => se
          se.status.should eq 1 
          $stderr.string.should match /invalid mail or pass/
        end
      end
    end

    context "when call with -i option" do
      it "should exec interactive mode" do
        argv = [ '-i' ]
        cli = Nicorepo::Cli.new
        cli.should_receive(:interactive_run)
        cli.run(argv)
      end
    end
  end

  describe "#interactive_run" do
    context "when entered 'exit'" do
      it "should return true" do
        repo = Nicorepo.new
        cli  = Nicorepo::Cli.new
        cli.stub!(:gets) { 'exit' }
        cli.interactive_run(repo).should be_true
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

  after(:all) do
    $stderr = @old_stderr
  end
end
