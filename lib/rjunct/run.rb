require "rake"
require_relative "version"
require_relative "options"
require_relative "model"
require_relative "parser"

def create_link(target, destination)
  relPath = Pathname.new(target).relative_path_from(Pathname.new(File.dirname(destination)) )
  sh("ln -s #{relPath} #{destination}")
end

def remove_links(path)
  if File.symlink?(path) then
    sh("rm #{path}")
  elsif FileTest.directory?(path)
    Dir.entries(path).each do |entry|
      if !entry.start_with?(".") then
        remove_links(path+"/"+entry)
      end
    end
  end
end

if ARGV.size == 0 then
  puts "#{NAME} (#{VERSION}) - build: #{BUILD}"
  puts "try: #{NAME} --help"
  exit(-1)
end

options = Options.new()
psfs = options.get(:psf)
repos = options.get(:repo)
mode = options.get(:mode)
verbose = options.get(:verbose)

puts "\n\t[ #{NAME} (#{VERSION}) ]\n\n"

repos.each do |repo|
  remove_links(repo.path)
end

if mode == :link then
  projects = Array.new
  psfs.each do |psf|
    puts "=> psf: #{psf}"
    parser = PsfParser.new(psf, verbose)
    parser.parse()
    projects.concat(parser.projects)
  end
  puts "=> #{projects.size} projects found"
  set = ProjectSet.new(projects, repos, verbose)
  
  puts "=> create links for renamed projects" 
  set.projects.each do |project|
    if project.valid && project.is_renamed_project? then
      fromPath = project.get_base_path()+"/"+project.remoteName
      toPath = project.get_base_path()+"/"+project.localName
      create_link(fromPath, toPath)
    end
  end
  
  puts "=> create links for subfolder projects" 
  set.projects.each do |project|
    if project.valid && !project.is_root_project? then
      fromPath = project.get_base_path()+"/"+project.localName
      toPath = project.repo.path+"/"+project.localName
      create_link(fromPath, toPath)
    end
  end
  
  puts "=> create links for cross-repo projects" 
  set.projects.each do |project|
    if project.valid then
      repos.each do |repo|
        if project.repo != repo then
          fromPath = project.get_base_path()+"/"+project.localName
          toPath = repo.path+"/"+project.localName
          create_link(fromPath, toPath)
        end
      end
    end
  end
end

puts "\n\t[ done. ]\n\n"

  