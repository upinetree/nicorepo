require 'yaml'

class Nicorepo
  class Cli
    class Config

      class ReadError < StandardError; end

      def initialize
        params = defaults.merge(load_config)
        @nums  = params["num"]
        @nests = params["nest"]
      end

      def num(cmd)
        @nums[cmd] || @nums["general"]
      end

      def nest(cmd)
        @nests[cmd] || @nests["general"]
      end

      private

      def load_config
        filename = File.expand_path('~/.nicorepo.yaml')
        return {} unless File.exist?(filename)

        open(filename) { |f| YAML.load(f.read) }
      end

      def defaults
        {
          "num" => {
            "general" => 10
          },
          "nest" => {
            "general" => 3
          }
        }
      end
    end
  end
end

