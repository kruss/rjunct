
class PsfParser
  
  # initilaize parser for a psf-file
  def initialize(psf)
    @psf = psf
  end
  
  def parse()
    @projects = Array.new
    @provider = :undefined
    parsePsfContent(IO.readlines(@psf))
  end
  
  attr_accessor :projects

private

  def parsePsfContent(lines)
      lines.each do |line|
        if @provider == :undefined && line.index("<provider") != nil then
          parsePsfProvider(line)
        end
        if @provider != :undefined && line.index("<project") != nil then
          parsePsfProject(line)
        end
      end
  end

  # svn: <provider id="org.eclipse.team.svn.core.svnnature">
  def parsePsfProvider(line)
    if line.index("svnnature") != nil then
      @provider = :svn
    else
      raise "unsupported psf-provider"
    end
  end
    
  # svn: <project reference="1.0.1,svn://10.40.38.84:3690/cppdemo/trunk/Dummy,Dummy,707311c94308001012d0ecc66e85647a;svn://10.40.38.84:3690/cppdemo;svn://10.40.38.84:3690/cppdemo;branches;tags;trunk;true;0fcde1b6-b28e-6845-9283-8db7a2e7b6eb;svn://10.40.38.84:3690/cppdemo;;false;;;22"/>
  def parsePsfProject(line)
    if @provider == :svn then
      lineParts = line.split(",")
      projectUrl = lineParts[1]
      localName = lineParts[2]
      urlParts = projectUrl.split("/")
      remoteName = urlParts[urlParts.size()-1]
      baseUrl = projectUrl.chomp("/"+remoteName)
      project = Project.new(baseUrl, remoteName, localName)
      @projects << project
    end
  end  
  
end
