
class ProjectSet
  
  def initialize(projects, repos)
    @projects = projects
    @repos = repos
    pack()
  end
  attr_accessor :projects
  attr_accessor :repos           
  
  def pack()
    @projects.each do |project|
      @repos.each do |repo|
        if project.baseUrl.eql?(repo.url) || project.baseUrl.start_with?(repo.url) then
          project.repo = repo
          repo.projects << project
          break
        end
      end
      if project.repo == nil then
        puts "WARNING repo not found: #{project.info}"
        project.valid = false
      end
    end
    @repos.each do |repo|
      repo.pack()
    end
  end
  
  def info()
    info = ""
    @repos.each do |repo|
      info += "#{repo.info}"
    end
    return info
  end
end

class Repository
  def initialize(url, path)
    @url = url
    @path = path
    @projects = Array.new
    @ignores = Array.new
  end
  attr_accessor :url
  attr_accessor :path
  attr_accessor :projects
  attr_accessor :ignores
  
  def pack()
    @projects.each do |project|
      if project.valid then
        project.repoPath = @url.eql?(project.baseUrl) ? "" : project.baseUrl[@url.size+1, project.baseUrl.size-1]
        projectPath = project.get_base_path()+"/"+project.remoteName
        if !FileTest.directory?(projectPath) then
          puts "WARNING path not found: #{projectPath}"
          project.valid = false
        end
      end
    end
  end
  
  def info()
    info = "- #{@url} => #{@path}\n"
    @projects.each do |project|
      info += "  |- #{project.info}\n"
    end
    return info
  end
  
  def add_ignore(path)
    ignore = Pathname.new(path).relative_path_from(Pathname.new(@path))
    if !@ignores.include?(ignore) then
      @ignores << ignore
    end
  end
end

class Project
  def initialize(baseUrl, remoteName, localName)
    @baseUrl = baseUrl
    @remoteName = remoteName
    @localName = localName
    @repo = nil
    @repoPath = nil
    @valid = true
  end
  attr_accessor :baseUrl
  attr_accessor :remoteName
  attr_accessor :localName
  attr_accessor :repo
  attr_accessor :repoPath
  attr_accessor :valid
  
  def is_renamed_project?()
    return !@remoteName.eql?(@localName)
  end
  
  def is_root_project?()
    return repoPath.eql?("")
  end
  
  def get_base_path()
    if is_root_project? then
      return @repo.path
    else
      return @repo.path+"/"+repoPath
    end
  end
  
  def info()
    info = "#{@baseUrl}/#{@remoteName}#{is_renamed_project? ? "|#{@localName}" : ""}"
    if @repo != nil then
      info = info + " => #{get_base_path()}/#{@remoteName}"
    end
    return info
  end
end
