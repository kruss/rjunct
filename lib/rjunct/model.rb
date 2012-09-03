
class ProjectSet
  
  def initialize(projects, verbose)
    @projects = projects
    @verbose = verbose
    find_repo_urls()
    find_project_urls()
  end
  attr_accessor :projects           # array of all psf-projects
  attr_accessor :repoUrls           # array of all repo urls
  attr_accessor :projectUrls        # hash of all project relative urls
  attr_accessor :repoPaths          # hash of all associated project repos
  attr_accessor :containerPaths     # hash of all associated project containers
  
  def map(repos)
    if @repoUrls.size != repos.size then
      puts "WARNING number of repositories does not match"
    end
    @repoPaths = Hash.new
    @containerPaths = Hash.new
    @projects.each do |project|
      repos.each do |repo|
        if @projectUrls[project] == nil then
          next
        elsif is_root_project?(project) then
          container = repo
          path = container+"/"+project.remoteName
        else
          container = repo+"/"+@projectUrls[project]
          path = container+"/"+project.remoteName
        end
        if FileTest.directory?(path) then
          if !is_mapped(project) then
            @repoPaths[project] = repo
            @containerPaths[project] = container
          else
            puts "WARNING project container is ambiguous: #{project.info} => #{@containerPaths[project]} ? #{container}"
          end
        end
      end
    end
    @projects.each do |project|
      if @containerPaths[project] == nil then
        puts "WARNING could not map project: #{project.info}"
      end
    end
  end
  
  # answer if file-system container found for given project
  def is_mapped(project)
    return @containerPaths[project] != nil
  end
  
  # answers if project is located within repo root
  def is_root_project?(project)
    return @projectUrls[project] != nil && @projectUrls[project].eql?("")
  end
  
private

  def find_repo_urls()
    @repoUrls = Array.new
    projectUrls = Array.new
    @projects.each do |project|
      if !projectUrls.include?(project.baseUrl) then
        projectUrls << project.baseUrl
      end
    end
    projectUrls.each do |url1|
      projectUrls.each do |url2|
        if is_base_url(url1, url2) then
          if @verbose then
            puts "repo: #{url1}"
          end
          @repoUrls << url1
          break
        end
      end
    end
  end

  def find_project_urls()
    @projectUrls = Hash.new
    @projects.each do |project|
      if @repoUrls.include?(project.baseUrl) then
        @projectUrls[project] = ""
      else
        @repoUrls.each do |repoUrl|
          if is_base_url(repoUrl, project.baseUrl) then
            @projectUrls[project] = project.baseUrl[repoUrl.size+1, project.baseUrl.size-1]
            break
          end
        end
      end
    end
  end
  
  # answer if a url is base of another
  def is_base_url(baseUrl, childUrl)
    return childUrl.start_with?(baseUrl) && childUrl.size > baseUrl.size
  end
end

class PsfProject
  def initialize(baseUrl, remoteName, localName)
    @baseUrl = baseUrl
    @remoteName = remoteName
    @localName = localName
  end
  attr_accessor :baseUrl
  attr_accessor :remoteName
  attr_accessor :localName
  
  def renamed?()
    return !remoteName.eql?(localName)
  end
  
  def info()
    return "#{baseUrl}/#{remoteName}#{renamed? ? "|#{localName}" : ""}"
  end
end