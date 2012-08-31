require "optparse"

class Options
  
  def initialize()
    @options = Hash.new
    parse()
  end
  
  def get(key)
    return @options[key]
  end
  
private

def parse()
  parser = OptionParser.new do |options|
    
    options.on("-p", "--psf LIST", "List of psf-files (path,...)") do |param|
      @options[:psf] = Array.new
      param.split(",").each do |part|
        path = clean_path(part)
        if !FileTest.file?(path) then
          raise "not a file: #{path}"
        end
        @options[:psf] << path
      end
    end
    
    options.on("-r", "--root LIST", "List of project-roots (path,...)") do |param|
      @options[:root] = Array.new
      param.split(",").each do |part|
        path = clean_path(part)
        if !FileTest.directory?(path) then
          raise "not a directory: #{path}"
        end
        @options[:root] << path
      end
    end
    
    options.on("-h", "--help", "Display this screen") do
      puts options
      exit(0)
    end
    
  end
  parser.parse!
end

def clean_path(path)
  if path == "." then
    return Dir.getwd
  elsif path == ".." then
    return Pathname.new(Dir.getwd+"/..").cleanpath.to_s
  else
    return Pathname.new(path.gsub(/\\/, "/")).cleanpath.to_s
  end
end
  
end