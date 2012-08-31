require_relative "version"
require_relative "options"
require_relative "model"
require_relative "parser"
require_relative "linker"

if ARGV.size == 0 then
  puts "#{NAME} (#{VERSION}) - build: #{BUILD}"
  puts "try: #{NAME} --help"
  exit(-1)
end

options = Options.new()

data = ProjectSet.new

options.get(:psf).each do |psf|
  parser = PsfParser.new(psf)
  parser.parse(data)
end

data.minimize()

data.projects.each do |project|
  options.get(:root).each do |root|
    path = "#{root}#{project.url != nil ? "/#{project.url}" : ""}/#{project.name}"
    if FileTest.directory?(path) then
      project.path = path
      break
    end
  end
end

data.projects.each do |project|
  puts "project: #{project.info}"
end

#linker = ProjectLinker.new(parser.data, options.get(:folders))
#linker.link()