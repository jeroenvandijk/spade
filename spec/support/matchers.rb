module SpecHelpers
  RSpec::Matchers.define :contain_line do |line|
    match do |io|
      if String === line
        matcher = /^#{Regexp.escape(line)}\s*$/
      else
        matcher = line
      end

      @actual = io.gets || ""
      @actual.chomp =~ matcher
    end

    failure_message_for_should do |io|
<<EOF
Expected:

  #{@actual.chomp}

To contain:

  #{line}

EOF
    end
  end

  def should_get_line(*lines)
    opts = Hash === lines.last ? lines.pop : {}

    lines.each do |line|
      if String === line
        line = /^#{Regexp.escape(line)}\s*$/
      end

      if opts[:io] == :stderr
        io = stderr
      else
        io = stdout
      end

      actual = io.gets || ""
      actual.chomp.should =~ line
      @match = line.match(actual.chomp)
    end
  end
end
