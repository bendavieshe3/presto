# spec/presto/cli/helpers/test_setup_helper.rb
module PrestoSpec
    module TestSetupHelper
      def with_test_env
        original_env = ENV.to_hash
        yield
      ensure
        ENV.clear
        ENV.update(original_env)
      end
  
      def setup_test_config
        FileUtils.mkdir_p(File.dirname(Presto::CLI::Config::CONFIG_FILE))
      end
    end
  end