/* global require */

var gulp = require('gulp');
var webserver = require('gulp-webserver');

var templateCache = require('gulp-angular-templatecache');
var minifyHtml = require('gulp-minify-html');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var streamqueue = require('streamqueue');
var jscs = require('gulp-jscs');
var umd    = require('gulp-umd');

gulp.task('minify', function() {
  var stream = streamqueue({objectMode: true});
  stream.queue(
              gulp.src('./src/*.html')
                  .pipe(minifyHtml({
                    empty: true,
                    spare: true,
                    quotes: true
                  }))
                  .pipe(templateCache({
                    module: 'schemaForm',
                    root: 'directives/decorators/bootstrap/strap/'
                  }))
    );

  stream.queue(
              gulp.src('./src/strap*.html')
                  .pipe(minifyHtml({
                    empty: true,
                    spare: true,
                    quotes: true
                  }))
                  .pipe(templateCache({
                    module: 'schemaForm',
                    root: 'directives/decorators/bootstrap/strap/'
                  }))
    );
  stream.queue(
              gulp.src('./src/ui*.html')
                  .pipe(minifyHtml({
                    empty: true,
                    spare: true,
                    quotes: true
                  }))
                  .pipe(templateCache({
                    module: 'schemaForm',
                    root: 'directives/decorators/bootstrap/uiselect/'
                  }))
    );
  stream.queue(gulp.src('./src/*.js'));

  stream.done()
        .pipe(concat('angular-schema-form-dynamic-select.min.js'))
        .pipe(umd({
            dependencies: function() {
              return [
                {name: 'schemaForm',
                amd:"angular-schema-form",
                cjs: 'angular-schema-form'},
              ];
            },
            exports: function() {return 'angularSchemaFormDynamicSelect';},
            namespace: function() {return 'angularSchemaFormDynamicSelect';}
            }))
        .pipe(uglify())
        .pipe(gulp.dest('.'));

});

gulp.task('non-minified-dist', function() {
  var stream = streamqueue({objectMode: true});
  stream.queue(
              gulp.src('./src/strap*.html')
                  .pipe(templateCache({
                    module: 'schemaForm',
                    root: 'directives/decorators/bootstrap/strap/'
                  }))
    );
  stream.queue(
              gulp.src('./src/ui*.html')
                  .pipe(templateCache({
                    module: 'schemaForm',
                    root: 'directives/decorators/bootstrap/uiselect/'
                  }))
    );
  stream.queue(gulp.src('./src/*.js'));

  stream.done()
        .pipe(concat('angular-schema-form-dynamic-select.js'))
        .pipe(umd({
            dependencies: function() {
              return [
                {name: 'schemaForm',
                amd:"angular-schema-form",
                cjs: 'angular-schema-form'},
              ];
            },
            exports: function() {return 'angularSchemaFormDynamicSelect';},
            namespace: function() {return 'angularSchemaFormDynamicSelect';}
            }))
        .pipe(gulp.dest('.'));

});

gulp.task('jscs', function() {
  gulp.src('./src/**/*.js')
      .pipe(jscs());
});

gulp.task('default', [
  'minify',
  'non-minified-dist'
]);

gulp.task('watch', function() {
  gulp.watch('./src/**/*', ['default']);
});

gulp.task('webserver', function() {
  gulp.src('.')
    .pipe(webserver({
      livereload: true,
      port: 8001,
      open: true
    }));
});
