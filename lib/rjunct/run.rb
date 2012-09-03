require_relative "version"
require_relative "options"
require_relative "model"
require_relative "parser"

def create_link(fromPath, toPath)
  puts "create link: #{fromPath} -> #{toPath}"
  # TODO
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

puts ">>> PARSE PSF-FILES <<<"
projects = Array.new
options.get(:psf).each do |psf|
  puts "=> #{psf}"
  parser = PsfParser.new(psf, verbose)
  parser.parse()
  projects.concat(parser.projects)
end
puts "=> #{projects.size} projects found"

puts ">>> CREATE PROJECT MAPPING <<<" 
set = ProjectSet.new(projects, verbose)
puts "=> #{set.repoUrls.size} repos found"
set.map(options.get(:repo))
if verbose then
  set.projects.each do |project|
    puts "#{project.info} => #{set.containerPaths[project]}/#{project.remoteName}"
  end
end
puts "=> #{set.containerPaths.size} container found"

puts ">>> CREATE LINKS (RENAMED PROJECTS) <<<".upcase 
set.projects.each do |project|
  if set.is_mapped(project) && project.renamed? then
    fromPath = set.containerPaths[project]+"/"+project.remoteName
    toPath = set.containerPaths[project]+"/"+project.localName
    create_link(fromPath, toPath)
  end
end

puts ">>> CREATE LINKS (SUBFOLDER PROJECTS) <<<".upcase 
set.projects.each do |project|
  if set.is_mapped(project) && !set.is_root_project?(project) then
    fromPath = set.containerPaths[project]+"/"+project.localName
    toPath = set.repoPaths[project]+"/"+project.localName
    create_link(fromPath, toPath)
  end
end

puts ">>> CREATE LINKS (REPO PROJECTS) <<<".upcase 
set.projects.each do |project|
  if set.is_mapped(project) then
    options.get(:repo).each do |repo|
      if !set.repoPaths[project].eql?(repo) then
        fromPath = set.containerPaths[project]+"/"+project.localName
        toPath = repo+"/"+project.localName
        create_link(fromPath, toPath)
      end
    end
  end
end
  