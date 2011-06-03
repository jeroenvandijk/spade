module Spade::CLI
  class Base < Thor
    include Thor::Actions

    source_root File.expand_path('../../templates', __FILE__)

    desc "owner", "Manage users for a package"
    subcommand "owner", Owner

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
      trap("SIGINT") { Spade::Server.shutdown }
      Spade::Server.run(options[:working], options[:port]);
    end

    desc "update", "Update package info in the current project"
    def update
      Spade::Bundle.update(options[:working], :verbose => options[:verbose])
    end

    desc "install [PACKAGE]", "Installs one or many spade packages"
    method_option :version,    :type => :string,  :default => ">= 0", :aliases => ['-v'],    :desc => 'Specify a version to install'
    method_option :prerelease, :type => :boolean, :default => false,  :aliases => ['--pre'], :desc => 'Install a prerelease version'
    def install(*packages)
      report_arity_error("install") and return if packages.size.zero?

      begin
        packages.each do |package|
          installed = Spade::Remote.new.install(package, options[:version], options[:prerelease])
          installed.each do |spec|
            say "Successfully installed #{spec.full_name}"
          end
        end
      rescue LibGems::InstallError => e
        abort "Install error: #{e}"
      rescue LibGems::GemNotFoundException => e
        abort "Can't find package #{e.name} #{e.version} available for install"
      rescue Errno::EACCES, LibGems::FilePermissionError => e
        abort e.message
      end
    end

    desc "installed [PACKAGE]", "Shows what spade packages are installed"
    def installed(*packages)
      local = Spade::Local.new
      index = local.installed(packages)
      print_specs(packages, index)
    end

    desc "uninstall [PACKAGE]", "Uninstalls one or many packages"
    def uninstall(*packages)
      local = Spade::Local.new
      if packages.size > 0
        packages.each do |package|
          if !local.uninstall(package)
            abort %{No packages installed named "#{package}"}
          end
        end
      else
        report_arity_error('uninstall')
      end
    end

    desc "login", "Log in with your Spade credentials"
    def login
      highline = HighLine.new
      say "Enter your Spade credentials."

      begin
        email = highline.ask "\nEmail:" do |q|
          next unless STDIN.tty?
          q.readline = true
        end

        password = highline.ask "\nPassword:" do |q|
          next unless STDIN.tty?
          q.echo = "*"
        end
      rescue Interrupt => ex
        abort "Cancelled login."
      end

      say "\nLogging in as #{email}..."

      if Spade::Remote.new.login(email, password)
        say "Logged in!"
      else
        say "Incorrect email or password."
        login
      end
    end

    desc "push", "Distribute your spade package"
    def push(package)
      remote = Spade::Remote.new
      if remote.logged_in?
        say remote.push(package)
      else
        say LOGIN_MESSAGE
      end
    end

    desc "yank", "Remove a specific package version release from SproutCutter"
    method_option :version, :type => :string,  :default => nil,   :aliases => ['-v'],    :desc => 'Specify a version to yank'
    method_option :undo,    :type => :boolean, :default => false,                        :desc => 'Unyank package'
    def yank(package)
      if options[:version]
        remote = Spade::Remote.new
        if remote.logged_in?
          if options[:undo]
            say remote.unyank(package, options[:version])
          else
            say remote.yank(package, options[:version])
          end
        else
          say LOGIN_MESSAGE
        end
      else
        say "Version required"
      end
    end

    desc "list", "View available packages for download"
    method_option :all,        :type => :boolean, :default => false, :aliases => ['-a'],    :desc => 'List all versions available'
    method_option :prerelease, :type => :boolean, :default => false, :aliases => ['--pre'], :desc => 'List prerelease versions available'
    def list(*packages)
      remote = Spade::Remote.new
      index  = remote.list_packages(packages, options[:all], options[:prerelease])
      print_specs(packages, index)
    end

    desc "new [NAME]", "Generate a new project skeleton"
    def new(name)
      ProjectGenerator.new(self,
        name, File.expand_path(name)).run
    end

    desc "build", "Build a spade package from a package.json"
    def build
      local = Spade::Local.new
      if local.logged_in?
        package = local.pack("package.json")
        if package.errors.empty?
          puts "Successfully built package: #{package.to_ext}"
        else
          failure_message = "Spade encountered the following problems building your package:"
          package.errors.each do |error|
            failure_message << "\n* #{error}"
          end
          abort failure_message
        end
      else
        abort LOGIN_MESSAGE
      end
    end

    desc "unpack [PACKAGE]", "Extract files from a spade package"
    method_option :target, :type => :string, :default => ".", :aliases => ['-t'], :desc => 'Unpack to given directory'
    def unpack(*paths)
      local = Spade::Local.new

      paths.each do |path|
        begin
          package     = local.unpack(path, options[:target])
          unpack_path = File.expand_path(File.join(Dir.pwd, options[:target], package.to_full_name))
          puts "Unpacked spade into: #{unpack_path}"
        rescue Errno::EACCES, LibGems::FilePermissionError => ex
          abort "There was a problem unpacking #{path}:\n#{ex.message}"
        end
      end
    end

    private

    def report_arity_error(name)
      self.class.handle_argument_error(self.class.tasks[name], nil)
    end

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
      Spade::MainContext.new(opts) do |ctx|

        requires = opts[:require]
        requires.each { |r| load(ctx, r) } if requires

        yield(ctx) if block_given?
      end
    end

    def print_specs(packages, index)
      spades = {}

      index.each do |(name, version, platform)|
        spades[name] ||= []
        spades[name] << version
      end

      if spades.size.zero?
        abort %{No packages found matching "#{packages.join('", "')}".}
      else
        spades.each do |name, versions|
          puts "#{name} (#{versions.sort.reverse.join(", ")})"
        end
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
