class Nicorepo
  class Report
    attr_reader :pages

    def initialize(request_num)
      @pages = []
      @request_num = request_num
    end

    def push(page)
      @pages.push(page)
    end

    def size
      raw.size
    end

    def raw
      @pages.map(&:raw)[0, @request_num]
    end

    def format(formatter = DefaultFormatter)
      formatter.process(raw)
    end

    class DefaultFormatter
      # to be implemented
    end
  end
end

