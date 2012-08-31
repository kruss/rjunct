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
task :example => [:install] do
  psfList = [ 
    "example/repo1/proj1/foo.psf", 
    "example/repo2/proj2/foo.psf" 
  ]
  rootList = [ 
    "example/repo1", 
    "example/repo2" 
  ]
  command = "#{spec.name} -p #{psfList.join(",")} -r #{rootList.join(",")}"
  sh(command)
end
