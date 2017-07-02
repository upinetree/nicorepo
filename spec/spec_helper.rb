require 'nicorepo'
require 'pry'
require 'netrc'
require 'vcr'

RSpec.configure do |config|
  config.example_status_persistence_file_path = "tmp/rspec-examples.txt"
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock

  record = ENV['UPDATE_VCR'] ? :all : :once
  c.default_cassette_options = { record: record }

  if record == :all
    mail, password = Netrc.read["nicovideo.jp"]
    c.filter_sensitive_data('<MAIL>') { mail }
    c.filter_sensitive_data('<PASSWORD>') { password }
  end
end
