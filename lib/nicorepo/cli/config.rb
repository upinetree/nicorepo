require 'yaml'

class Nicorepo

  class Cli
  
    class Config
      def account
        root = File.expand_path('../../../../', __FILE__)

        begin
          confs = open(File.join(root, 'config.yaml')) { |f| YAML.load(f.read) }
        rescue
          raise AccountError
        end
       
        raise AccountError if confs["mail"].nil? || confs["pass"].nil?
        return {mail: confs["mail"], pass: confs["pass"]}
      end
    end
  
  end

end
