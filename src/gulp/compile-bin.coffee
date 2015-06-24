###

# Compile bin folder

`gulp compile-bin`


---
###


gulp   = require "gulp"
coffee = require "gulp-coffee"
plumber = require "gulp-plumber"
inject = require "gulp-inject-string"
cson = require "gulp-cson"
# paths

mainPath = ["./src/index.coffee"]
binPath = ["./src/rodney.coffee"]
watchPath = ["./src/rodney.coffee","./src/index.coffee"]
targetPath = "./"

module.exports = ()->

  gulp.src(binPath).pipe(plumber()).pipe(coffee({bare:true})).pipe(inject.prepend("#!/usr/bin/env node\n")).pipe(gulp.dest(targetPath))
  gulp.src(mainPath).pipe(plumber()).pipe(coffee({bare:true})).pipe(gulp.dest(targetPath))

  return

module.exports.watch = watchPath