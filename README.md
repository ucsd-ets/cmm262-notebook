# cmm262-notebook

## Build instructions

1. clone the repo
2. make a git branch
3. checkout your git branch & make changes within it
4. push branch to github & monitor the build under the actions tab
5. if build successful, pull in your new tag from dockerhub and test it `docker run -p 3000:3000 -ti ucsdets/cmm262-notebook:<your branch name> jupyter notebook --ip 127.0.0.1`
6. if your tests are successful, merge your branch into the stable branch by creating & merging a pull request
