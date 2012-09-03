require "rubygems/package_task"

spec = Gem::Specification.load("gemspec")
Gem::PackageTask.new(spec){ |pkg| }

task :default => [:version, :gem]

task :version do
  File.open("lib/#{spec.name}/version.rb", "w") do |file|  
    file.puts "NAME = \"#{spec.name}\""
    file.puts "VERSION = \"#{spec.version}\""
    file.puts "BUILD = \"#{Time.new()}\""
  end
end
  
desc "Install the gem"
task :install => [:default] do
  sh("gem install pkg/#{spec.name}-#{spec.version}.gem")
end

desc "Uninstall the gem"
task :uninstall do
  sh("gem uninstall #{spec.name}")
end

desc "Remove temporary artifacts"
task :clean do
  sh("rm -rf pkg/#{spec.name}-#{spec.version}")
end

desc "Run the example"
task :example => [:install, :unlink] do
  psfList = [ 
    "example/repo1/proj1/foo.psf", 
    "example/repo2/proj1/foo.psf" 
  ]
  repoList = [ 
    "http://repo1/foo/trunk/dev=example/repo1", 
    "http://repo2/foo/trunk/dev=example/repo2" 
  ]
  command = "#{spec.name} -p #{psfList.join(",")} -r #{repoList.join(",")}"
  sh(command)
end

desc "Remove example artifacts"
task :unlink do
  remove_symlinks("example")
end

def remove_symlinks(item)
  if FileTest.directory?(item)
    Dir.entries(item).each do |entry|
      if !entry.start_with?(".") then
        remove_symlinks(item+"/"+entry)
      end
    end
  elsif File.symlink?(item) then
    sh("rm #{item}")
  end
end
