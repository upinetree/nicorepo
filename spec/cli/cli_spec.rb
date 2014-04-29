require 'spec_helper'

describe Nicorepo::Cli do
  before(:all) do
    @old_stderr = $stderr
    $stderr = StringIO.new
  end

  describe "#run" do

    let(:cli) { Nicorepo::Cli.new }
    before(:each) { cli.stub(:configure) }

    context "when login failed" do
      it "should exit with error massage" do
        begin
          Nicorepo::Cli::Config.any_instance.stub(:account).and_return({mail: "invalid@mail.com", pass: "invalid_pass"})
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
        it "should recieve reports of live" do
          Nicorepo.any_instance.should_receive(:lives).and_return([Nicorepo::Report.new])
          cli.run([ 'lives' ])
        end
      end
    end
  end

  describe "#interactive_run" do
    context "when entered 'exit'" do
      it "should return true" do
        cli = Nicorepo::Cli.new
        Readline.stub(:readline) { 'exit' }
        cli.interactive_run.should be_true
      end
    end
  end

  describe "#open_url" do
    context "with 1" do
      before do
        @cli = Nicorepo::Cli.new
        @reports = [ Nicorepo::Report.new ]
      end

      it "should succeed to open url in browser with first report's url" do
        @reports.first.url = 'http://www.nicovideo.jp'
        expect{ @cli.open_url(@reports, 1, {dry_run: true}) }.to be_true
      end

      it "should raise error when url is nil" do
        @reports.first.url = nil
        expect{ @cli.open_url(@reports, 1, {dry_run: true}) }.to raise_error
      end

      it "should raise error when url is wrongs" do
        @reports.first.url = 'hoge://piyo'
        expect{ @cli.open_url(@reports, 1, {dry_run: true}) }.to raise_error
      end
    end
  end

  after(:all) do
    $stderr = @old_stderr
  end
end
