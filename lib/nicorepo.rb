require 'nicorepo/filter'
require 'nicorepo/page'

require 'netrc'

class Nicorepo
  PER_PAGE = 25
  MAX_PAGES_DEFAULT = 20

  def session
    # TODO: handle expiration
    @session ||= (
      mail, pass = Netrc.read["nicovideo.jp"]
      Nicorepo::Client::Auth.new.login(mail, pass)
    )
  end

  def all(request_num = PER_PAGE, params = {})
    params = params.merge(max_pages: request_num / PER_PAGE + 1)

    fetch(:all, request_num, params)
  end

  def videos(request_num, params = {})
    fetch(:videos, request_num, params)
  end

  def lives(request_num, params = {})
    fetch(:lives, request_num, params)
  end

  def fetch(filter_type, request_num, params = {})
    max_pages = params.delete(:max_pages) || MAX_PAGES_DEFAULT
    filter = Nicorepo::Filter.generate(filter_type)
    page = Nicorepo::Page.new(session, filter)

    reports =
      max_pages.times.each_with_object([]) do |_, reports|
        break reports if reports.size >= request_num

        reports.concat(page.reports)
        page = page.next
      end

    reports[0, request_num]
  end
end

require "nicorepo/version"
