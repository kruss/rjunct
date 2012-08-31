GEM_NAME = "rjunct"
GEM_VERSION = "0.1.0"

spec = Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.description = 'compose a workspace on base of a psf-file'
  s.version = GEM_VERSION
  s.author = "Kevin russ"
  s.email = "kevin.russ@esrlabs.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "a simple type-trainer"
  s.files = FileList["lib/**/*.rb"].to_a
  s.require_path = "lib"
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
  s.executables = [GEM_NAME]
end