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

  def all(request_num = PER_PAGE, options = {})
    options = options.merge(limit_page: request_num / PER_PAGE + 1)

    fetch(:all, request_num, options)
  end

  def videos(request_num, options = {})
    fetch(:videos, request_num, options)
  end

  def lives(request_num, options = {})
    fetch(:lives, request_num, options)
  end

  # === Params
  #
  # * limit_page - Integer
  # * request_num - Integer
  # * options - Hash
  #
  # === Options
  #
  # * from - Time or String
  # * to - Time or String
  #
  # fetch `from` newer `to` older reports
  #
  def fetch(filter_type, request_num, options = {})
    limit_page = options[:limit_page] || MAX_PAGES_DEFAULT
    cursor = cursor_from_time(options[:from])
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

     from = Time.parse(options[:from]) if from === String
     (from.to_f * 1000).floor
  end
end

require "nicorepo/version"
