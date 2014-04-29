require 'yaml'

class Nicorepo
  class Cli
    class Config

      class ReadError < StandardError; end

      def initialize
        params = defaults.merge(load_config)
        @request_nums  = params["request_num"]
        @limit_pages = params["limit_page"]
      end

      def request_num(cmd)
        @request_nums[cmd] || @request_nums["general"]
      end

      def limit_page(cmd)
        @limit_pages[cmd] || @limit_pages["general"]
      end

      private

      def load_config
        filename = File.expand_path('~/.nicorepo.yaml')
        return {} unless File.exist?(filename)

        open(filename) { |f| YAML.load(f.read) }
      end

      def defaults
        {
          "request_num" => {
            "general" => 10
          },
          "limit_page" => {
            "general" => 3
          }
        }
      end
    end
  end
end

