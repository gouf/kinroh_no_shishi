require 'yaml'

class KinrohNoShishi
  class WorktimeConfig
    class << self
      def load(template_name)
        YAML.load_file(File.join(__dir__, 'config', "#{template_name}.yml"))
            .transform_keys(&:to_sym)
      end
    end
  end
end
