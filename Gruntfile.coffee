"use strict"
LIVERELOAD_PORT = 35727
lrSnippet = require("connect-livereload")(port: LIVERELOAD_PORT)
proxySnippet = require('grunt-connect-proxy/lib/utils').proxyRequest
allProject = [
    'project_demo'
]
# var conf = require('./conf.'+process.env.NODE_ENV);
mountFolder = (connect, dir) ->
    connect.static require("path").resolve(dir)


# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->
    require("load-grunt-tasks") grunt
    require("time-grunt") grunt
    # configurable paths
    yeomanConfig =
        app: "client"
        dist: "dist"

    try
        yeomanConfig.app = require("./bower.json").appPath or yeomanConfig.app

    grunt.loadNpmTasks('grunt-ssh-deploy')
    grunt.loadNpmTasks('grunt-contrib-compress')
    initConfig =
        yeoman: yeomanConfig
        compress:
            main:
                options:
                    archive: './' + grunt.template.today('yyyymmdd-HHMMss') + '.zip'
                    mode: 'gzip'
                files: [
                    src: 'dist/**'
                ]
        watch:
            coffee:
                files: ["<%= yeoman.app %>/scripts/**/*.coffee"]
                tasks: ["coffee:dist"]

            typescript:
                files: ["<%= yeoman.app %>/scripts/**/*.ts"]
                tasks: ["typescript:dist"]

            compass:
                files: ["<%= yeoman.app %>/styles/**/*.{scss,sass}"]
                tasks: ["compass:server"]

            less:
                files: ["<%= yeoman.app %>/styles-less/**/*.less"]
                tasks: ["less:server"]

            livereload:
                options:
                    livereload: LIVERELOAD_PORT

                files: [
                    "<%= yeoman.app %>/index.html"
                    "<%= yeoman.app %>/views/**/*.html"
                    "<%= yeoman.app %>/styles/**/*.scss"
                    "<%= yeoman.app %>/styles-less/**/*.less"
                    ".tmp/styles/**/*.css"
                    "{.tmp,<%= yeoman.app %>}/scripts/**/*.js"
                    "<%= yeoman.app %>/images/**/*.{png,jpg,jpeg,gif,webp,svg}"
                ]

        connect:
            options:
                port: 8000
                hostname: "0.0.0.0"
#proxy config

#            proxies: [
#                context: '/'
#                host: '127.0.0.1'
#                port: 8889
#                changeOrigin: true
#                keepalive: true
#                rewrite:
#                    '^/':'/settle/'
#                headers:
#                    host:'127.0.0.1:8889'
#            ]
#            proxies: [
#                context: '/'
#                host: 'xxx.xx.com'
#                changeOrigin: true
#                keepalive: true
#                headers:
#                    host:'xxx.xx.com'
#                rewrite:
#                    '^/':'/admin/'
#            ]
#            proxies:[
#                context: '/'
#                host: 'xxx.xx.com'
#                changeOrigin: true
#                keepalive: true
#                headers: host: 'xxx.xx.com'
#            ]
            proxies: [
                context: '/'
                host: '127.0.0.1'
                port: 5000
            ]

            livereload:
                options:
                    middleware: (connect) ->
                        [lrSnippet, mountFolder(connect, ".tmp"), mountFolder(connect, yeomanConfig.app), proxySnippet]

            test:
                options:
                    middleware: (connect) ->
                        [mountFolder(connect, ".tmp"), mountFolder(connect, "test")]

            dist:
                options:
                    middleware: (connect) ->
                        [mountFolder(connect, yeomanConfig.dist)]

        open:
            server:
                url: "http://localhost:<%= connect.options.port %>"

        clean:
            dist:
                files: [
                    dot: true
                    src: [".tmp", "<%= yeoman.dist %>/*", "!<%= yeoman.dist %>/.git*"]
                ]

            server: ".tmp"
            all: "dist"

        jshint:
            options:
                jshintrc: ".jshintrc"

            all: ["Gruntfile.js", "<%= yeoman.app %>/scripts/**/*.js"]

        compass:
            options:
                sassDir: "<%= yeoman.app %>/styles"
                cssDir: ".tmp/styles"
                generatedImagesDir: ".tmp/styles/ui/images/"
                imagesDir: "<%= yeoman.app %>/styles/ui/images/"
                javascriptsDir: "<%= yeoman.app %>/scripts"
                fontsDir: "<%= yeoman.app %>/fonts"
                importPath: "<%= yeoman.app %>/bower_components"
                httpImagesPath: "styles/ui/images/"
                httpGeneratedImagesPath: "styles/ui/images/"
                httpFontsPath: "fonts"
                relativeAssets: true
            dist:
                options:
                    outputStyle: 'compressed'
                    debugInfo: false
                    noLineComments: true
            server:
                options:
                    debugInfo: true
            forvalidation:
                options:
                    debugInfo: false
                    noLineComments: false
# if you want to use the compass config.rb file for configuration:
# compass:
#   dist:
#     options:
#       config: 'config.rb'

        less:
            server:
                options:
                    strictMath: true
                    dumpLineNumbers: true
                    sourceMap: true
                    sourceMapRootpath: ""
                    outputSourceFiles: true
                files: [
                    expand: true
                    cwd: "<%= yeoman.app %>/styles-less"
                    src: "main.less"
                    dest: ".tmp/styles"
                    ext: ".css"
                ]
            dist:
                options:
                    cleancss: true,
                    report: 'min'
                files: [
                    expand: true
                    cwd: "<%= yeoman.app %>/styles-less"
                    src: "main.less"
                    dest: ".tmp/styles"
                    ext: ".css"
                ]


        coffee:
            server:
                options:
                    sourceMap: true
# join: true,
                    sourceRoot: ""
                files: [
                    expand: true
                    cwd: "<%= yeoman.app %>/scripts"
                    src: "**/*.coffee"
                    dest: ".tmp/scripts"
                    ext: ".js"
                ]
            dist:
                options:
                    sourceMap: false
                    sourceRoot: ""
                files: [
                    expand: true
                    cwd: "<%= yeoman.app %>/scripts"
                    src: "**/*.coffee"
                    dest: ".tmp/scripts"
                    ext: ".js"
                ]

        typescript:
            server:
                options:
                    module: 'commonjs'
                    target: 'ES5'
                    sourceMap: true
                    sourceRoot: ''
                files: [
                    expand: true
                    cwd: "<%= yeoman.app %>/scripts"
                    src: ["**/**/*.ts"]
                    dest: ".tmp/scripts"
                    ext: '.js'
                ]
            dist:
                options:
                    module: 'commonjs'
                    target: 'ES5'
                    sourceMap: true
                    sourceRoot: ''
                files: [
                    expand: true
                    cwd: "<%= yeoman.app %>/scripts"
                    src: ["**/**/*.ts"]
                    dest: ".tmp/scripts"
                    ext: '.js'
                ]


        useminPrepare:
            html: "<%= yeoman.app %>/index.html"
            options:
                dest: "<%= yeoman.dist %>"
                flow:
                    steps:
                        js: ["concat"]
                        css: ["cssmin"]
                    post: []


# 'css': ['concat']
        usemin:
            html: ["<%= yeoman.dist %>/**/*.html", "!<%= yeoman.dist %>/bower_components/**"]
            css: ["<%= yeoman.dist %>/styles/**/*.css"]
            options:
                dirs: ["<%= yeoman.dist %>"]

        htmlmin:
            dist:
                options: {}

#removeCommentsFromCDATA: true,
#                    // https://github.com/yeoman/grunt-usemin/issues/44
#                    //collapseWhitespace: true,
#                    collapseBooleanAttributes: true,
#                    removeAttributeQuotes: true,
#                    removeRedundantAttributes: true,
#                    useShortDoctype: true,
#                    removeEmptyAttributes: true,
#                    removeOptionalTags: true
                files: [
                    expand: true
                    cwd: "<%= yeoman.app %>"
                    src: ["*.html", "views/*.html"]
                    dest: "<%= yeoman.dist %>"
                ]


# Put files not handled in other tasks here
        copy:
            dist:
                files: [
                    expand: true
                    dot: true
                    cwd: "<%= yeoman.app %>"
                    dest: "<%= yeoman.dist %>"
                    src: [
                        "favicon.ico"
# bower components that has image, font dependencies
                        "bower_components/**/*.js"
                        "bower_components/**/*.css"
                        "bower_components/font-awesome/css/*"
                        "bower_components/font-awesome/fonts/*"
                        "bower_components/weather-icons/css/*"
                        "bower_components/weather-icons/font/*"
                        "fonts/**/*"
                        "i18n/**/*"
                        "images/**/*"
# "styles/bootstrap/**/*"
                        "styles/fonts/**/*"
                        "styles/img/**/*"
                        "styles/ui/images/*"
                        "views/**/*"
                        "scripts/**/**/*.json"
                    ]
                ,
                    expand: true
                    cwd: ".tmp"
                    dest: "<%= yeoman.dist %>"
                    src: ["styles/**", "assets/**"]
                ,
                    expand: true
                    cwd: ".tmp"
                    dest: "<%= yeoman.dist %>"
                    src: ["scripts/**", "scripts/**"]
                ,
                    expand: true
                    cwd: ".tmp/images"
                    dest: "<%= yeoman.dist %>/images"
                    src: ["generated/*"]
                ]

            styles:
                expand: true
                cwd: "<%= yeoman.app %>/styles"
                dest: ".tmp/styles/"
                src: "**/*.css"

        concurrent:
            server: ["coffee:server", "typescript:server", "compass:server", "copy:styles"]
            dist: ["coffee:dist", "typescript:server", "compass:dist", "copy:styles", "htmlmin"]
            lessServer: ["coffee:server", "less:server", "copy:styles"]
            lessDist: ["coffee:dist", "less:dist", "copy:styles", "htmlmin"]

        cssmin:
            options:
                keepSpecialComments: '0'
            dist: {}    # usemin takes care of that

        concat:
            options:
                separator: grunt.util.linefeed + ';' + grunt.util.linefeed
            dist: {}   # usemin takes care of that
        environments:
            options:
                local_path: 'dist'
            deploy:
                options:
                    host: '10.211.55.1'
                    username: 'root'
                    privateKey: require('fs').readFileSync('~/.ssh/id_rsa')
                    deploy_path: '/root/'
                    releases_to_keep: 1
                    tag: 'dist'
                    before_deploy: ''
                    after_deploy: ''

    for i in allProject
        arr = []
        for j in allProject
            if i != j then arr.push "dist/views/" + j + "/**", "dist/scripts/" + j + "/**"
        initConfig.clean[i] = arr
        initConfig.compress[i] =
            options:
                archive: './' + i + '-' + grunt.template.today('yyyymmdd-HHMMss') + '.zip'
                mode: 'zip'
            files: [
                src: 'dist/**'
            ]
    grunt.initConfig initConfig

    grunt.registerTask "server", (target) ->
        return grunt.task.run(["build", "connect:dist:keepalive"])  if target is "dist"
        grunt.task.run ["clean:server", "concurrent:server", "configureProxies", "connect:livereload", "watch"]

    grunt.registerTask "lessServer", (target) ->
        return grunt.task.run(["lessBuild", "connect:dist:keepalive"])  if target is "dist"
        grunt.task.run ["clean:server", "concurrent:lessServer", "connect:livereload", "watch"]

    grunt.registerTask "build", (target)->
        grunt.task.run ["clean:dist", "useminPrepare", "concurrent:dist", "copy:dist"]
        grunt.task.run ["clean:" + target] if target? and initConfig.clean[target]?
        grunt.task.run ["cssmin", "concat", "usemin"]
        grunt.task.run ["compress:" + target] if target? and initConfig.compress[target]?
        grunt.task.run ["clean:all"]

    #    grunt.registerTask "build", ["clean:dist", "useminPrepare", "concurrent:dist", "copy:dist", "cssmin", "concat", "usemin","compress","clean:all"]

    grunt.registerTask "lessBuild", ["clean:dist", "useminPrepare", "concurrent:lessDist", "copy:dist", "cssmin",
        "concat", "uglify", "usemin"]
    grunt.registerTask "deploy", ->
        grunt.task.run ["clean:dist", "useminPrepare", "concurrent:dist", "copy:dist"]
        grunt.task.run ["clean:demo"]
        grunt.task.run ["cssmin", "concat", "usemin", "ssh_deploy:deploy", "clean:all"]
    grunt.registerTask "default", ["server"]
