# ==========================================================================
# Project:   Spade - CommonJS Runtime
# Copyright: ©2010 Strobe Inc. All rights reserved.
# License:   Licened under MIT license (see LICENSE)
# ==========================================================================

module Spade
  EXENAME = 'spade'

  class CLI < Thor
    default_task :exec

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

      shell = Spade::Shell.new
      context(:with => shell) do |ctx|
        shell.ctx = ctx
        puts "help() for help. quit() to quit."
        puts "Spade #{Spade::VERSION} (V8 #{V8::VERSION})"
        puts "WORKING=#{options[:working]}" if options[:verbose]

        trap("SIGINT") { puts "^C" }
        repl ctx
      end
    end

    map  "-e" => "exec"
    desc "exec [FILENAME]", "Executes filename or stdin"
    def exec(*exec_args)
      filename = exec_args.shift
      exec_args = ARGV.dup
      exec_args.shift if exec_args.first == 'exec' # drop exec name
      exec_args.shift # drop exec name

      if filename
        puts options[:working]
        filename = File.expand_path filename, Dir.pwd
        throw "#{filename} not found" unless File.exists?(filename)
        fp      = File.open filename
        source  = File.basename filename
        rootdir = Spade.discover_root filename

        # peek at first line.  If it is poundhash, skip. else reopen file
        unless fp.readline =~ /^\#\!/
          fp.close
          fp = File.open filename
        end
      else
        fp = $stdin
        source = '<stdin>'
        rootdir = options[:working]
      end

      begin
        # allow for poundhash
        context(:argv => exec_args, :rootdir => rootdir) do |ctx|
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
      require 'rack'
      require 'rack/static'

      rootdir = Spade.discover_root options[:working]
      static = Rack::Static.new(nil, :urls => ['/'], :root => rootdir)
      static = Rack::ShowStatus.new(Rack::ShowExceptions.new(static))

      trap("SIGINT") { Rack::Handler::WEBrick.shutdown }
      Rack::Handler::WEBrick.run static, :Port => options[:port].to_i
    end

    desc "update", "Update package info in the current project"
    def update
      Bundle.update(options[:working], :verbose => options[:verbose])
    end

    desc "install [PACKAGE]", "Installs one or many spade packages"
    def install(*packages)
      begin
        packages.each do |package|
          installed = Remote.install(package)
          installed.each do |spec|
            say "Successfully installed #{spec.full_name}"
          end
        end
      rescue Gem::InstallError => e
        say "Install error: #{e}"
      rescue Gem::GemNotFoundException => e
        say "Can't find package #{e.name} #{e.version} available for install"
      rescue Gem::FilePermissionError => e
        say e.message
      end
    end

    desc "login", "Log in with your Spade credentials"
    def login
      highline = HighLine.new
      say "Enter your Spade credentials."

      email = highline.ask "\nEmail:" do |q|
        next unless STDIN.tty?
        q.readline = true
      end

      password = highline.ask "\nPassword:" do |q|
        next unless STDIN.tty?
        q.echo = "*"
      end

      say "\nLogging in as #{email}..."

      if Remote.login(email, password)
        say "Logged in!"
      else
        say "Incorrect email or password."
      end
    end

    desc "push", "Distribute your spade package"
    def push(package)
      if Remote.api_key
        say Remote.push(package)
      else
        say "Please login first with `spade login`."
      end
    end

    protected

    # Replace start such that if you don't pass an original task, we try to 
    # treat the command as exec
    def self.dispatch(meth, given_args, given_opts, config) #:nodoc:
      saved_args = given_args.dup
      begin
        super(meth, given_args, given_opts, config)
      rescue Thor::UndefinedTaskError => e
        super('exec', saved_args, given_opts, config)
      end
    end

    private

    def repl(ctx)
      ctx.reactor.next_tick do
        line = Readline.readline("#{EXENAME}> ", true)
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
      MainContext.new(opts) do |ctx|

        requires = opts[:require]
        requires.each { |r| load(ctx, r) } if requires

        yield(ctx) if block_given?
      end
    end
  end
end
