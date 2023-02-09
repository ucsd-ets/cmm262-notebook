# cmm262-notebook

## Build instructions

1. clone the repo
2. make a git branch
3. checkout your git branch & make changes within it
4. push branch to github & monitor the build under the actions tab
5. if build successful, pull in your new tag from dockerhub and test it `launch-scipy-ml.sh -P Always -i ghcr.io/ucsd-ets/cmm262-notebook:TAG`
6. if your tests are successful, merge your branch into the stable branch by creating & merging a pull request
