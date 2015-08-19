(function (gulp, gulpLoadPlugins) {

    'use strict';

    var $ = gulpLoadPlugins({ pattern: '*', lazy: true }),
        _ = {
            theme: 'public/themes/project',
            vendor: 'public/themes/project/thirdparty',
            src: 'public/themes/project/assets/src',
            build: 'public/themes/project/assets/build'
        };

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ jsonlint
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    gulp.task('jsonlint', function() {
        return gulp.src([
            'package.json',
            'bower.json',
            '.bowerrc',
            '.jshintrc',
            '.jscs.json'
        ])
        .pipe($.plumber())
        .pipe($.jsonlint())
        .pipe($.jsonlint.reporter())
        .pipe($.notify({
            message: '<%= options.date %> ✓ jsonlint: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ jshint
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    gulp.task('jshint', function() {
        return gulp.src([
            'gulpfile.js',
            _.src + '/js/**/*.js',
            '!' + _.vendor + '/**/*.js',
            'test/spec/{,*/}*.js'
        ])
        .pipe($.plumber())
        .pipe($.jshint('.jshintrc'))
        .pipe($.jshint.reporter('default'))
        .pipe($.notify({
            message: '<%= options.date %> ✓ jshint: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ js
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    gulp.task('js-predom', function() {
        return gulp.src([
            _.vendor + '/modernizr/modernizr.js'
            // _.vendor + '/picturefill/src/picturefill.js'
        ])
        .pipe($.plumber())
        .pipe($.concat('lib-predom.js'))
        .pipe($.uglifyjs({
            mangle: {
                except: ['$','require','exports','define']
            }
        }))
        .pipe($.gulp.dest(_.build + '/js'))
        .pipe($.size()).pipe($.notify({
            message: '<%= options.date %> ✓ js: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    gulp.task('js-vendor-postdom', function() {
        return gulp.src([
            _.vendor + '/jquery/dist/jquery.min.js'
            // _.vendor + '/gush/gush.js',
            // _.vendor + '/droposaurus/droposaurus.js',
            // _.vendor + '/pagr/pagr.js',
            // _.src + '/js/countdown.js'
        ])
        .pipe($.plumber())
        .pipe($.concat('lib-postdom.js'))
        .pipe($.gulp.dest(_.build + '/js'))
        .pipe($.size()).pipe($.notify({
            message: '<%= options.date %> ✓ vendor-postdom: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    gulp.task('js-postdom', ['js-vendor-postdom'], function() {

        return gulp
            .src([
                _.build + '/js/lib-postdom.js',
                _.src + '/js/app.js',
            ])
            .pipe($.concat('all.js'))
            .pipe($.uglifyjs({
                mangle: {
                    except: ['$','require','exports','define']
                }
            }))
            .pipe(gulp.dest(_.build + '/js'))
            .pipe($.size())
            .pipe($.notify({
               message: '<%= options.date %> ✓ concat / uglify: <%= file.relative %>',
               templateOptions: {
                   date: new Date()
               }
            }));
    });


    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ styles
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    gulp.task('styles', function() {
        return $.rubySass(_.src + '/scss/', {
            sourcemap: true
        })
        .on('error', $.util.log)
        //.pipe($.sourcemaps.write())
        .pipe(gulp.dest(_.build + '/css'))
        .pipe($.notify({
            message: '<%= options.date %> ✓ styles: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    gulp.task('styles-build', function() {
        return $.rubySass(_.src + '/scss/', {
            sourcemap: false,
            style: 'compressed'
        })
        .on('error', $.util.log)
        .pipe($.csso())
        .pipe(gulp.dest(_.build + '/css'))
        .pipe($.notify({
            message: '<%= options.date %> ✓ styles: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    gulp.task('styles-blessed', ['styles'], function() {
        return gulp.src(_.build + '/css/main.css')
        .pipe($.bless())
        .pipe(gulp.dest(_.build + '/css/blessed'))
        .pipe($.notify({
            message: '<%= options.date %> ✓ styles-bless: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    gulp.task('styles-blessed-build', ['styles-build'], function() {
        return gulp.src(_.build + '/css/main.css')
        .pipe($.bless())
        .pipe(gulp.dest(_.build + '/css/blessed'))
        .pipe($.notify({
            message: '<%= options.date %> ✓ styles-bless: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ svg
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    gulp.task('svg', function() {
        return gulp.src([
            _.src + '/img/**/*.svg'
        ])
        .pipe($.plumber())
        .pipe($.svgmin([{ removeDoctype: false }, { removeComments: false }]))
        .pipe(gulp.dest(_.build + '/img')).pipe($.size()).pipe($.notify({
            message: '<%= options.date %> ✓ svg: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ img
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    gulp.task('img', function() {
        return gulp.src([
            _.src + '/img/**/*.{png,jpg,jpeg,gif,ico}'
        ]).pipe($.plumber())
        .pipe(
            // does some weird stuff on deploy
            // $.cache(
                $.imagemin({
                    optimizationLevel: 3,
                    progressive: true,
                    interlaced: true
                })
            // )
        )
        .pipe(gulp.dest(_.build + '/img')).pipe($.size()).pipe($.notify({
            message: '<%= options.date %> ✓ img: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ copy
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    gulp.task('copy', function() {
        return gulp.src([
            _.src + '/font/**/*'
        ])
        .pipe($.plumber())
        .pipe(gulp.dest(_.build + '/font'))
        .pipe($.size()).pipe($.notify({
            message: '<%= options.date %> ✓ copy: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ copy video
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    gulp.task('copyVideo', function() {
        return gulp.src([
            _.src + '/video/**/*'
        ])
        .pipe($.plumber())
        .pipe(gulp.dest(_.build + '/video'))
        .pipe($.size()).pipe($.notify({
            message: '<%= options.date %> ✓ copy: <%= file.relative %>',
            templateOptions: {
                date: new Date()
            }
        }));
    });

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ watch
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    gulp.task('watch', function() {

        // Watch style files
        $.watch([_.src + '/scss/**/*.scss', _.vendor + '/**/*.scss'], function() {
            gulp.start('styles-blessed');
        });

        // Watch script files
        $.watch([_.src + '/js/**/*', _.vendor + '/**/*.js'], function() {
            gulp.start('js-predom');
             //gulp.start('js-postdom');
            gulp.start('jshint');
        });

        // Watch image files
        $.watch([_.src + '/img/*'], function() {
            gulp.start('img');
            gulp.start('svg');
        });

        // Watch font files
        $.watch([_.src + '/font/*'], function() {
            gulp.start('copy');
        });

        // Watch video files
        $.watch([_.src + '/video/*'], function() {
            gulp.start('copyVideo');
        });

    });

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ clean
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

    gulp.task('clean', function (cb) {
      $.del([
        _.build + '/img',
        _.build + '/js',
        _.build + '/css',
        _.build + '/font'
      ], cb);
    });

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ alias
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    gulp.task('test', ['jsonlint', 'jshint']);
    gulp.task('build', ['test', 'img', 'svg', 'js-predom', 'js-postdom', 'styles-blessed-build', 'copy', 'copyVideo']);

    //|**~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //| ✓ default
    //'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
    gulp.task('default', ['clean'], function() {
        gulp.start('build');
    });

}(require('gulp'), require('gulp-load-plugins')));
