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
    
    @options[:psf] = Array.new
    options.on("-p", "--psf LIST", "List of psf-files (path,...)") do |param|
      param.split(",").each do |part|
        path = clean_path(part)
        if !FileTest.file?(path) then
          raise "not a file: #{path}"
        end
        @options[:psf] << path
      end
    end
    
    @options[:repo] = Array.new
    options.on("-r", "--repo LIST", "List of repo-folders (path,...)") do |param|
      param.split(",").each do |part|
        path = clean_path(part)
        if !FileTest.directory?(path) then
          raise "not a directory: #{path}"
        end
        @options[:repo] << path
      end
    end
    
    @options[:verbose] = false
    options.on("-v", "--verbose", "Run in verbose mode") do
      @options[:verbose] = true
    end
    
    options.on("-h", "--help", "Display this screen") do
      puts options
      exit(0)
    end
    
  end
  parser.parse!
  
  if @options[:psf].size == 0 then
    raise "no psf specified"
  end
  if @options[:repo].size == 0 then
    raise "no repo specified"
  end
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