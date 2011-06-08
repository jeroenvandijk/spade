require 'thor'

module Spade
  module Runtime
    module CLI
      class Base < Thor

        class_option :working, :required => false,
          :default => Spade.discover_root(Dir.pwd),
          :aliases => ['-w'],
          :desc    => 'Root working directory.'

        class_option :verbose, :type => :boolean, :default => false,
          :aliases => ['-V'],
          :desc => 'Show additional debug information while running'

        class_option :require, :type => :array, :required => false,
          :aliases => ['-r'],
          :desc => "optional JS files to require before invoking main command"

        map  "-i" => "console", "--interactive" => "console"
        desc "console", "Opens an interactive JavaScript console"
        def console
          require 'readline'

          shell = Spade::Runtime::Shell.new
          context(:with => shell) do |ctx|
            shell.ctx = ctx
            puts "help() for help. quit() to quit."
            puts "Spade #{Spade::Runtime::VERSION} (V8 #{V8::VERSION})"
            puts "WORKING=#{options[:working]}" if options[:verbose]

            trap("SIGINT") { puts "^C" }
            repl ctx
          end
        end

        map  "-e" => "exec"
        desc "exec [FILENAME]", "Executes filename or stdin"
        def exec(*)
          exec_args = ARGV.dup
          arg = exec_args.shift while arg != "exec" && !exec_args.empty?

          filename = exec_args.shift
          puts "Filename: #{filename}" if options[:verbose]

          if filename
            puts "Working: #{options[:working]}" if options[:verbose]
            filename = File.expand_path filename, Dir.pwd
            throw "#{filename} not found" unless File.exists?(filename)
            fp      = File.open filename
            source  = File.basename filename
            rootdir = Spade.discover_root filename

            caller_id = nil
            if rootdir
              json_path = File.join(rootdir, 'package.json')
              if File.exist?(json_path)
                package_json = JSON.parse(File.read(json_path))
                caller_id = "#{package_json['name']}/main"
              end
            end

            # peek at first line.  If it is poundhash, skip. else rewind file
            unless fp.readline =~ /^\#\!/
              fp.rewind
            end

            # Can't set pos on STDIN so we can only do this for files
            if options[:verbose]
              pos = fp.pos
              puts fp.read
              fp.pos = pos
            end
          else
            fp = $stdin
            source = '<stdin>'
            rootdir = options[:working]
            caller_id = nil
          end

          if options[:verbose]
            puts "source: #{source}"
            puts "rootdir: #{rootdir}"
            puts "caller_id: #{caller_id}"
          end

          begin
            # allow for poundhash
            context(:argv => exec_args, :rootdir => rootdir, :caller_id => caller_id) do |ctx|
              ctx.eval(fp, source) # eval the rest
            end
          rescue Interrupt => e
            puts; exit
          end
        end

        map  "server" => "preview"
        desc "preview", "Starts a preview server for testing"
        long_desc %[
          The preview command starts a simple file server that can be used to
          load JavaScript-based apps in the browser.  This is a convenient way to
          run apps in the browser instead of having to setup Apache on your
          local machine.  If you are already loading apps through your own web
          server (for ex using Rails) the preview server is not required.
        ]
        method_option :port, :type => :string, :default => '4020',
          :aliases => ['-p'],
          :desc => 'Port number'
        def preview
          require 'spade/server'
          trap("SIGINT") { Spade::Runtime::Server.shutdown }
          Spade::Runtime::Server.run(options[:working], options[:port]);
        end

        desc "update", "Update package info in the current project"
        def update
          Spade::Runtime::Bundle.update(options[:working], :verbose => options[:verbose])
        end

        private

          def repl(ctx)
            ctx.reactor.next_tick do
              line = Readline.readline("spade> ", true)
              begin
                result = ctx.eval(line, '<console>')
                puts result unless result.nil?
              rescue V8::JSError => e
                puts e.message
                puts e.backtrace(:javascript)
              rescue StandardError => e
                puts e
                puts e.backtrace.join("\n")
              end
              repl(ctx)
            end
          end

          # Loads a JS file into the context.  This is not a require; just load
          def load(cxt, libfile)
            begin
              content = File.readlines(libfile)
              content.shift if content.first && (content.first =~ /^\#\!/)
              cxt.eval(content*'')
              #cxt.load(libfile)
            rescue V8::JSError => e
              puts e.message
              puts e.backtrace(:javascript)
            rescue StandardError => e
              puts e
            end
          end

          # Initialize a context to work against.  This will load also handle 
          # autorequires
          def context(opts={})
            opts[:rootdir] ||= options[:working]
            opts[:verbose] = options[:verbose]
            Spade::Runtime::MainContext.new(opts) do |ctx|

              requires = opts[:require]
              requires.each { |r| load(ctx, r) } if requires

              yield(ctx) if block_given?
            end
          end

          def method_missing(meth, *)
            if File.exist?(meth.to_s)
              ARGV.unshift("exec")
              invoke :exec
            else
              super
            end
          end

      end
    end
  end
end
