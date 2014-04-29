class Nicorepo
  class Report
    attr_accessor :body, :title, :url, :author, :kind, :date

    def initialize(attrs)
      @body   = attrs[:body]
      @title  = attrs[:title]
      @url    = attrs[:url]
      @author = attrs[:author]
      @kind   = attrs[:kind]
      @date   = attrs[:date]
    end
  end
end

