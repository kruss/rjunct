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

psfList = [ 
  "example/repo1/proj1/foo.psf", 
  "example/repo2/proj1/foo.psf" 
]
repoList = [ 
  "http://repo1/foo/trunk/dev=example/repo1", 
  "http://repo2/foo/trunk/dev=example/repo2" 
]

desc "Run the example"
task :example => [:install] do
  sh("#{spec.name} -v -p #{psfList.join(",")} -r #{repoList.join(",")}")
end

desc "Run the example (none verbose)"
task :example_quiet => [:install] do
  sh("#{spec.name} -p #{psfList.join(",")} -r #{repoList.join(",")}")
end

desc "Remove example artifacts"
task :example_clean => [:install] do
  sh("#{spec.name} -v -m clean -r #{repoList.join(",")}")
end
