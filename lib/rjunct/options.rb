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
    options.banner = "#{NAME} (#{VERSION}) - build: #{BUILD}"
    
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
    options.on("-r", "--repo LIST", "List of repo url to folder mapping (url=path,...)") do |param|
      param.split(",").each do |part|
        segments = part.split("=")
        if segments.size != 2 then
          raise "invalid format: #{part} #{segments.size}"
        end
        url = segments[0]
        path = clean_path(segments[1])
        if !FileTest.directory?(path) then
          raise "not a directory: #{path}"
        end
        @options[:repo] << Repository.new(url, path)
      end
    end
    
    @options[:mode] = :link
    options.on("-m", "--mode MODE", "Run mode <[link]|clean>") do |param|
      if param.eql?("clean") then
        @options[:mode] = :clean
      end
    end

    @options[:verbose] = false
    options.on("-v", "--verbose", "Verbose mode") do
      @options[:verbose] = true
    end
    
    options.on("-h", "--help", "Display this screen") do
      puts options
      exit(0)
    end
    
  end
  parser.parse!
  
  if @options[:mode] == :link  && @options[:psf].size == 0 then
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