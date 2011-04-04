require 'spade/installer'

module Spade
  class DependencyInstaller < Gem::DependencyInstaller

    # Had to overwrite this all just to change the match from /gem$/ to /spd$/
    def find_spec_by_name_and_version(gem_name,
                                      version = Gem::Requirement.default,
                                      prerelease = false)
      spec_and_source = nil

      glob = if File::ALT_SEPARATOR then
               gem_name.gsub File::ALT_SEPARATOR, File::SEPARATOR
             else
               gem_name
             end

      local_gems = Dir["#{glob}*"].sort.reverse

      unless local_gems.empty? then
        local_gems.each do |gem_file|
          next unless gem_file =~ /spd$/
          begin
            spec = Gem::Format.from_file_by_path(gem_file).spec
            spec_and_source = [spec, gem_file]
            break
          rescue SystemCallError, Gem::Package::FormatError
          end
        end
      end

      if spec_and_source.nil? then
        dep = Gem::Dependency.new gem_name, version
        dep.prerelease = true if prerelease
        spec_and_sources = find_gems_with_sources(dep).reverse

        spec_and_source = spec_and_sources.find { |spec, source|
          Gem::Platform.match spec.platform
        }
      end

      if spec_and_source.nil? then
        raise Gem::GemNotFoundException.new(
          "Could not find a valid spd '#{gem_name}' (#{version}) locally or in a repository",
          gem_name, version, @errors)
      end

      @specs_and_sources = [spec_and_source]
    end

    # Overwrite this to use our custom installer
    def install dep_or_name, version = Gem::Requirement.default
      if String === dep_or_name then
        find_spec_by_name_and_version dep_or_name, version, @prerelease
      else
        dep_or_name.prerelease = @prerelease
        @specs_and_sources = [find_gems_with_sources(dep_or_name).last]
      end

      @installed_gems = []

      gather_dependencies

      @gems_to_install.each do |spec|
        last = spec == @gems_to_install.last
        # HACK is this test for full_name acceptable?
        next if @source_index.any? { |n,_| n == spec.full_name } and not last

        # TODO: make this sorta_verbose so other users can benefit from it
        say "Installing spd #{spec.full_name}" if Gem.configuration.really_verbose

        _, source_uri = @specs_and_sources.assoc spec
        begin
          local_gem_path = Gem::RemoteFetcher.fetcher.download spec, source_uri,
                                                               @cache_dir
        rescue Gem::RemoteFetcher::FetchError
          next if @force
          raise
        end

        inst = Spade::Installer.new local_gem_path,
                                  :bin_dir             => @bin_dir,
                                  :development         => @development,
                                  :env_shebang         => @env_shebang,
                                  :force               => @force,
                                  :format_executable   => @format_executable,
                                  :ignore_dependencies => @ignore_dependencies,
                                  :install_dir         => @install_dir,
                                  :security_policy     => @security_policy,
                                  :source_index        => @source_index,
                                  :user_install        => @user_install,
                                  :wrappers            => @wrappers

        spec = inst.install

        @installed_gems << spec
      end

      @installed_gems
    end

  end
end
