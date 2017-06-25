require 'nicorepo/request'
require 'nicorepo/filter'
require 'nicorepo/page'
require 'nicorepo/report'

require 'netrc'

class Nicorepo
  PER_PAGE = 25
  MAX_PAGES_DEFAULT = 20

  def session
    # TODO: handle expiration
    @session ||= (
      mail, pass = Netrc.read["nicovideo.jp"]
      raise LoginAccountError, "mail and password is not defined in .netrc as a machine nicovideo.jp" if mail.nil? || pass.nil?
      Request::Auth.new.login(mail, pass)
    )
  end

  def reset_session
    @session = nil
  end

  def all(request_num = PER_PAGE, params = {})
    params = params.merge(limit_page: request_num / PER_PAGE + 1)

    fetch(:all, request_num, params)
  end

  def videos(request_num, params = {})
    fetch(:videos, request_num, params)
  end

  def lives(request_num, params = {})
    fetch(:lives, request_num, params)
  end

  # @params
  #   * limit_page - Integer
  #   * from - Time or String
  def fetch(filter_type, request_num, params = {})
    limit_page = params[:limit_page] || MAX_PAGES_DEFAULT
    cursor = cursor_from_time(params[:from])
    filter = Filter.generate(filter_type)
    page = Page.new(session, filter, cursor)

    limit_page.times.each_with_object(Report.new(request_num)) do |_, report|
      report.push(page)
      break report if report.size >= request_num

      page = page.next
    end
  end

  private

  def cursor_from_time(from)
    return unless from

     from = Time.parse(params[:from]) if from === String
     (from.to_f * 1000).floor
  end
end

require "nicorepo/version"
