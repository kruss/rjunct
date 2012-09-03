require "rake"
require_relative "version"
require_relative "options"
require_relative "model"
require_relative "parser"

def create_link(fromPath, toPath)
  sh("ln -s #{fromPath} #{toPath}")
end

def remove_link(path)
  puts "remove link: #{path}"
  # TODO
end

if ARGV.size == 0 then
  puts "#{NAME} (#{VERSION}) - build: #{BUILD}"
  puts "try: #{NAME} --help"
  exit(-1)
end

options = Options.new()
verbose = options.get(:verbose)

projects = Array.new
options.get(:psf).each do |psf|
  puts "=> psf: #{psf}"
  parser = PsfParser.new(psf, verbose)
  parser.parse()
  projects.concat(parser.projects)
end
puts "=> #{projects.size} projects found"
 
set = ProjectSet.new(projects, options.get(:repo), verbose)

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
    options.get(:repo).each do |repo|
      if project.repo != repo then
        fromPath = project.get_base_path()+"/"+project.localName
        toPath = repo.path+"/"+project.localName
        create_link(fromPath, toPath)
      end
    end
  end
end

  