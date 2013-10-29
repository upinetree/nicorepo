require 'yaml'

class Nicorepo

  class Cli
  
    class Config

      class ReadError < StandardError; end
      class AccountError < StandardError; end

      def initialize
        @params = {}
      end

      def read
        root = File.expand_path('../../../../', __FILE__)

        begin
          @params = open(File.join(root, 'config.yaml')) { |f| YAML.load(f.read) }
        rescue
          raise ReadError
        end

        raise AccountError if @params["mail"].nil? || @params["pass"].nil?
      end

      def account
        return {mail: @params["mail"], pass: @params["pass"]}
      end
    end
  
  end

end
