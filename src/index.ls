require! {
  "gulp-util": gutil
  'LiveScript': livescript
  'through2'
  "vinyl-sourcemaps-apply": apply-source-map
}

module.exports = (opts=bare: true) -> 
  transform = (file, encoding, done) ->
    # Sanity checks
    if file.is-null!
      return done [null, file]
    else if file.is-stream!
      return done new gutil.PluginError \gulp-livescriptr, 'Streaming not supported'
    
    # Compile
    input = file.contents.to-string \utf8
    ast = livescript.ast livescript.tokens input, raw: opts.lex
    output = ast.compile-root opts
    
    # Setup filenames for sourcemapping
    output.set-file file.path.replace file.base, ''
    # Commented-out files that pass through unchanged need this set
    file.path = file.path.replace file.history.base, ''
    
    # Sourcemap
    output = output.to-string-with-source-map!
    output.map._file = ''
    apply-source-map file, output.map.to-string!
    file.contents = new Buffer output.code
    
    done null, file

  through2.obj transform
  
