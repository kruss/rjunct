
class Linker
  
  def initialize(options)
    @psfs = options.get(:psf)
    @repos = options.get(:repo)
    @mode = options.get(:mode)
    @verbose = options.get(:verbose)
  end
  
  def run()
    puts "\n\t[ #{NAME} (#{VERSION}) ]\n\n"
    clean_repos()
    if @mode == :link then
      create_model()
      create_links()
    end
    puts "\n\t[ done. ]\n\n"
  end
  
private

  def clean_repos()
    @removed = 0
    @repos.each do |repo|
      puts "=> remove links: #{repo.path}"
      remove_links(repo.path)
    end
    puts "=> #{@removed} links removed"
  end
  
  def create_model()
    projects = Array.new
    @psfs.each do |psf|
      puts "=> parse psf: #{psf}"
      parser = PsfParser.new(psf)
      parser.parse()
      projects.concat(parser.projects)
    end
    puts "=> #{projects.size} projects found"
    @model = ProjectSet.new(projects, @repos)
    if @verbose then
      puts @model.info()
    end
  end
  
  def create_links()
    @created = 0
    link_renamed_projects()
    link_subfolders_to_root()
    link_projects_across_repos()
    link_projects_to_subfolders()
    puts "=> #{@created} links created"
  end
  
  def link_renamed_projects()
    puts "=> link renamed projects" 
    @model.projects.each do |project|
      if project.valid && project.is_renamed_project? then
        fromPath = project.get_base_path()+"/"+project.remoteName
        toPath = project.get_base_path()+"/"+project.localName
        create_link(fromPath, toPath)
      end
    end
  end

  def link_subfolders_to_root()
    puts "=> link subfolders to root" 
    @model.projects.each do |project|
      if project.valid && !project.is_root_project? then
        fromPath = project.get_base_path()+"/"+project.localName
        toPath = project.repo.path+"/"+project.localName
        create_link(fromPath, toPath)
      end
    end
  end
  
  def link_projects_across_repos()
    puts "=> link projects accross repos" 
    @model.projects.each do |project|
      if project.valid then
        @repos.each do |repo|
          if project.repo != repo then
            fromPath = project.get_base_path()+"/"+project.localName
            toPath = repo.path+"/"+project.localName
            create_link(fromPath, toPath)
          end
        end
      end
    end
  end
  
  def link_projects_to_subfolders()
    puts "=> link projects to subfolders" 
    @model.projects.each do |project1|
      if project1.valid && !project1.is_root_project? then
        @repos.each do |repo|
          repo.projects.each do |project2|
            if project1.repo != project2.repo || !project1.repoPath.eql?(project2.repoPath) then
              fromPath = project2.get_base_path()+"/"+project2.localName
              toPath = project1.get_base_path()+"/"+project2.localName
              create_link(fromPath, toPath)
            end
          end
        end
      end
    end
  end
  
  def create_link(target, destination)
    if !File.exists?(destination) then
      relPath = Pathname.new(target).relative_path_from(Pathname.new(File.dirname(destination)) )
      execute("ln -s #{relPath} #{destination}")
      @created =  @created + 1
    end
  end
  
  def remove_links(path)
    if File.symlink?(path) then
      execute("rm #{path}")
      @removed =  @removed + 1
    elsif FileTest.directory?(path)
      Dir.entries(path).each do |entry|
        if !entry.start_with?(".") then
          remove_links(path+"/"+entry)
        end
      end
    end
  end
  
  def execute(command)
    if @verbose then
      puts "#{command}"
    end
    out = `#{command} 2>&1`
    status = $?.to_i
    if status != 0 then
      raise "CMD failed: #{command} (#{status})"
    end
  end
  
end