@echo off
@color 0a

start https://haxe.org/download/version/4.3.6/
echo Download a 4.3.6 version of Haxe
pause

start https://www.git-scm.com/
echo Download a Git for installing a git version of Haxe Libraries
pause

cd ..
haxelib --global install hmm
haxelib --global run hmm setup
hmm install
haxelib run lime setup
n
haxelib --never run lime rebuild systools windows
y
