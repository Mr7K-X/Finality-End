start https://haxe.org/download/version/4.3.6/
echo Download a 4.3.6 version of haxe
pause

start https://www.git-scm.com/
echo Download a Git for downloading a git versions
pause

cd ..
haxelib --global install hmm
haxelib --global run hmm setup
hmm install
haxelib run lime setup