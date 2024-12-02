# spec/presto/cli/helpers/output_helper.rb
module PrestoSpec
    module OutputHelper
      def capture_output(&block)
        original_stdout = $stdout
        $stdout = StringIO.new
        block.call
        $stdout.string
      ensure
        $stdout = original_stdout
      end
    end
  end