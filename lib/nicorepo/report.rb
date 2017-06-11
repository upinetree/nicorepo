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
      @pages.map(&:raw).flatten[0, @request_num]
    end

    def format(formatter = DefaultFormatter)
      formatter.process(raw)
    end

    class DefaultFormatter
      require 'time'

      class << self
        def process(raw)
          raw.map do |h|
            title, url = infer_body(h)

            {
              sender: nickname(h),
              topic: topic(h),
              title: title,
              link: url,
              created_at: created_at(h)
            }
          end
        end

        private

        def nickname(h)
          h.dig('senderNiconicoUser', 'nickname')
        end

        def topic(h)
          case h['topic']
          when 'nicovideo.user.video.upload'
            '動画投稿'
          when 'nicovideo.user.video.kiriban.play'
            "#{h.dig('actionLog', 'viewCount')}再生達成"
          when 'nicovideo.user.video.advertise'
            '動画広告'
          when 'nicovideo.user.mylist.add.video'
            'マイリスト登録'
          when 'live.user.program.onairs'
            '生放送開始'
          else
            h['topic']
          end
        end

        def created_at(h)
          Time.parse(h['createdAt'])
        end

        # @return [String, String] title, url
        def infer_body(h)
          candidate_keys = %w(video program)
          candidate_keys.each do |k|
            if h[k]
              id, title = h[k].fetch_values('id', 'title') if h[k]
              return title, watch_url(id, k)
            end
          end

          ['', '']
        end

        def watch_url(id, key)
          base =
            case key
            when 'video'
              "http://www.nicovideo.jp/watch/"
            when 'program'
              "http://live.nicovideo.jp/watch/"
            end

          base + id
        end
      end
    end
  end
end

