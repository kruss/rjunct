NAME = "rjunct"
VERSION = "0.1.0"
BUILD = "2012-09-03 22:09:02 +0200"
HELP = <<EOF
OVERVIEW

If working with git repositories synchronized to svn repositories based on an eclipse psf,-
rjunct will create project links to support psf-specific renamings and subfolders.

OPTIONS

    -p, --psf LIST                   List of psf-files (path,...)
    -r, --repo LIST                  List of repo url to folder mapping (url=path,...)
    -m, --mode MODE                  Run mode: [link]|clean
    -v, --verbose                    Verbose mode
    -h, --help                       Display this screen

EXAMPLE

Two separate svn repos used with following structure:

svn://repo1/foo/trunk/dev => path: workspace/repo1
 |- svn://repo1/foo/trunk/dev/proj1 => path: workspace/repo1/proj1 (containing psf for repo1)
 |- svn://repo1/foo/trunk/dev/sub1/proj1|proj2 => path: workspace/repo1/sub1/proj1
svn://repo2/foo/trunk/dev => path: workspace/repo2
 |- svn://repo2/foo/trunk/dev/proj1|proj3 => path: workspace/repo2/proj1 (containing psf for repo2)
 |- svn://repo2/foo/trunk/dev/sub1/proj1|proj4 => path: workspace/repo2/sub1/proj1

Would be linked / unliked with the following options (separate psf-files are supported, but not mandatory):

link: 
	-p workspace/repo1/proj1/foo.psf,workspace/repo2/proj1/foo.psf 
	-r svn://repo1/foo/trunk/dev=workspace/repo1,svn://repo2/foo/trunk/dev=workspace/repo2
	
unlink: 

	-m clean 
	-r svn://repo1/foo/trunk/dev=workspace/repo1,svn://repo2/foo/trunk/dev=workspace/repo2

This will result in symlinks within git repositories so that each project could see all others,-
as if a flat project structure would be given.

Also .gitignore files will be updated within git repositories to ignore the created links ;-)
EOF
