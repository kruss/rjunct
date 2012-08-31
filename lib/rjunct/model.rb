
class ProjectSet
  def initialize()
    @projects = Array.new
  end
  attr_accessor :projects
  
  def minimize()
    urls = Array.new
    projects.each do |project|
      if !urls.include?(project.url) then
        urls << project.url
      end
    end
    containers = Array.new
    urls.each do |url1|
      urls.each do |url2|
        if !url1.eql?(url2) && url2.start_with?(url1) then
          containers << url1
        end
      end
    end
    projects.each do |project|
      if containers.include?(project.url) then
        project.url = nil
      else
        containers.each do |container|
          if project.url.start_with?(container) then
            project.url = project.url[container.size+1, project.url.size-1]
            break
          end
        end
      end
    end
  end
end

class Project
  def initialize(url, name, link = nil)
    @url = url
    @name = name
    if link != nil && !name.eql?(link) then
      @link = link
    end
    @path = nil
  end
  attr_accessor :url
  attr_accessor :name
  attr_accessor :link
  attr_accessor :path
  
  def info()
    return "#{@url != nil ? "#{@url}/" : ""}#{@name}#{@link != nil ? " (#{@link})" : ""}#{@path != nil ? " => #{@path}" : ""}"
  end
end