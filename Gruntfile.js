module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    bower: {
      install: {}
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
    clean: ['lib/', 'node_modules']
  });

  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-bower-task');
  grunt.loadNpmTasks('grunt-mocha-test');

  grunt.registerTask('installDeps', ['bower:install']);
  grunt.registerTask('develop', ['installDeps', 'watch:test']);
  grunt.registerTask('unit-test', ['mochaTest']);
  
  grunt.registerTask('default', ['installDeps']);
};
