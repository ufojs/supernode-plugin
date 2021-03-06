var os = require('os');

module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    bower: {
      install: {
        options: {
          copy: false
        }
      }
    },
    uglify: {
      build: {
        src: 'lib/supernode.bundle.js',
        dest: 'lib/supernode.bundle.min.js'
      }
    },
    browserify: {
      dist: {
        files: {
          'lib/supernode.bundle.js': ['src/main.coffee'],
        },
        options: {
          transform: ['coffeeify'],
          browserifyOptions: {
            extensions: ['.coffee']
          },
          bundleOptions: {
            standalone: 'ufo'
          }
        }
      }
    },
    mochaTest: {
      test: {
        options: {
          require: 'coffee-script/register',
          reporter: 'spec'
        },
        src: ['test/*.coffee']
      }
    },
    watch: {
      test: {
        files: ['test/*.coffee', 'src/*.coffee'],
        tasks: 'mochaTest'
      }
    },
    shell: {
      copyStack: {
        command: function() {
          return 'cp lib/supernode.bundle.min.js chrome/ufo-app/';
        }
      },
      copyAppHTML: {
        command: function() {
          return 'cp pages/app.html chrome/ufo-app/app.html';
        }
      },
      runchrome: {
        command: function() {
          var chrome = null;
          var currentOS = os.type();
          if(currentOS=='Darwin')
            chrome = '/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome';
          return chrome + ' --load-and-launch-app=chrome/ufo-app' 
                        + ' --user-data-dir=/tmp/testufo';
        }
      }
    },
    karma: {
      unit: {
        configFile: 'integration-test/karma.conf.js'
      }
    },
    clean: [
      'lib/',
      'node_modules/',
      'chrome/ufo-app/supernode.bundle.min.js',
      'chrome/ufo-app/app.html'
    ]
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-bower-task');
  grunt.loadNpmTasks('grunt-mocha-test');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-browserify');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-karma');

  grunt.registerTask('installDeps', ['bower:install']);
  grunt.registerTask('develop', ['installDeps', 'watch:test']);
  grunt.registerTask('unit-test', ['mochaTest']);
  grunt.registerTask('compile', ['installDeps', 'browserify', 'uglify']);
  grunt.registerTask('bundle', ['compile', 'shell:copyStack', 'shell:copyAppHTML']);
  grunt.registerTask('integration-test', ['bundle', 'karma']);
  grunt.registerTask('run-chrome', ['unit-test', 'integration-test', 'shell:runchrome']);
  
  grunt.registerTask('default', ['bundle']);
};
