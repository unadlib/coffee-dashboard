window.project = 'project_demo'
window.setRoute = ->
    LS = window.localStorage
    if !LS['ngStorage-allNav'] then return
    allNav = JSON.parse(LS['ngStorage-allNav']) if LS['ngStorage-allNav']?
    hash = window.location.hash
    thisNavArray = hash.replace('#', '').split('/')
    thisNav = if thisNavArray.length < 3 then "/#{thisNavArray[1]}" else "/#{thisNavArray[1]}/:id"
    #    thisNav = hash.replace('#','').replace(/\/\d+/g,(if /\d+/.test(hash) then '/:id' else ''))
    if !allNav and Object.prototype.toString.call(allNav) != "[object Array]" then return false
    for i in allNav
        if i and i.url == thisNav
            LS['ngStorage-historyNav'] = JSON.stringify i
            break
        if !i.child or i.child.length == 0 then continue
        for s in i.child
            if s and s.url == thisNav
                LS['ngStorage-historyNav'] = JSON.stringify s
                break
    LS['ngStorage-historyNav']
do-> #after route
    window.setRoute()
require.config({
    waitSeconds: 120
    urlArgs: "_=" + (+new Date())
    baseUrl: "scripts"
    paths: {
        "angular": "../bower_components/angular/angular.min"
        "async": "../bower_components/requirejs/as"
        "angularAMD": "../bower_components/angularAMD/angularAMD.min"
        "ngload": "../bower_components/angularAMD/ngload.min"
        "angular-route": "../bower_components/angular-route/angular-route.min"
        "angular-dragdrop": "../bower_components/angular-dragdrop/src/angular-dragdrop.min"
        "angular-animate": "../bower_components/angular-animate/angular-animate.min"
        "angular-resource": "../bower_components/angular-resource/angular-resource.min"
        "angular-restmod": "../bower_components/angular-restmod/dist/angular-restmod-bundle.min"
        "angular-restmod-plus-preload": "../bower_components/angular-restmod/dist/plugins/preload"
        "angular-restmod-plus-dirty": "../bower_components/angular-restmod/dist/plugins/dirty"
        "angular-select-ui": "../bower_components/angular-ui-select/dist/select.min"
        "angular-sanitize": "../bower_components/angular-sanitize/angular-sanitize.min"
        "jquery": "../bower_components/jquery/dist/jquery.min"
        "jquery-ui": "../bower_components/jquery-ui/jquery-ui.min"
        "lodash": "../bower_components/lodash/dist/lodash.underscore.min"
        "highcharts": "../bower_components/highcharts/highcharts"
        "highcharts-ng": "../bower_components/highcharts-ng/dist/highcharts-ng.min"
        "bootstrap": "../bower_components/angular-bootstrap/ui-bootstrap-tpls.min"
        "spinner": "../bower_components/jquery-spinner/dist/jquery.spinner.min"
        "slider": "../bower_components/seiyria-bootstrap-slider/dist/bootstrap-slider.min"
        "toastr": "../bower_components/toastr/toastr"
        "file-input": "../bower_components/bootstrap-file-input/bootstrap.file-input"
        "slimscroll": "../bower_components/jquery.slimscroll/jquery.slimscroll.min"
        "gauge": "../bower_components/gauge.js/dist/gauge.min"
        "rangy-selectionsaverestore": "../bower_components/rangy/rangy-selectionsaverestore.min"
        "rangy": "../bower_components/rangy/rangy-core.min"
        "textAngular-rangy": "../bower_components/textAngular/dist/textAngular-rangy.min"
        "textAngular-sanitize": "../bower_components/textAngular/dist/textAngular-sanitize.min"
        "textAngular": "../bower_components/textAngular/dist/textAngular.min"
        "tag-input": "../bower_components/ng-tags-input/ng-tags-input.min"
        "ngInfiniteScroll": "../bower_components/ngInfiniteScroll/build/ng-infinite-scroll.min"
        "ngStorage": "../bower_components/ngstorage/ngStorage.min"
        "Raphael": "../bower_components/raphael/raphael-min"
        "ngDraggable": "../bower_components/ngDraggable/ngDraggable"
        "hightGallery": "../bower_components/lightgallery/dist/js/lightgallery.min"
        "hightGallery-thumbnail": "../bower_components/lightgallery/dist/js/lg-thumbnail.min"
        "hightGallery-fullscreen": "../bower_components/lightgallery/dist/js/lg-fullscreen.min"
        "ngTagsInput": "../bower_components/ng-tags-input/ng-tags-input.min"
        "ng-flow": "../bower_components/ng-flow/ng-flow-2.6.1/dist/ng-flow.min"
        "ng-file-upload": "../bower_components/ng-file-upload/ng-file-upload.min"
        "angular-clipboard": "../bower_components/angular-clipboard/angular-clipboard"
        "ngWYSIWYG": "../bower_components/ngWYSIWYG/dist/wysiwyg.min"
        "chinaMap": "directives/chinaMap"
        "Model_factory": "model/factory"
        "Model_services": "model/services"
        "sysDirectives": "directives/main"
        "sysFactory": "factory/main"
        "sysController": "controller/main"
        "datatable": "directives/datatable"
        "date": "directives/date"
        "logger": "factory/logger"
        "promise": "user/promise"
        "config": "#{project}/config"
        "angular-restmod-style": "#{project}/RESTAPI"
        "Program_Fields": "#{project}/field"
        "Program_Model": "#{project}/model"
        "Program_Directive": "#{project}/directive"
        "Program_Factory": "#{project}/factory"
    },
    shim: {
        "angular":
            deps: ["jquery"]
            exports: "angular"
        "angularAMD": ["angular"]
        "angular-route": ["angular"]
        "angular-animate": ["angular"]
        "angular-restmod": ["angular"]
        "angular-sanitize": ["angular"]
        "Model_factory": ["angular"]
        "Model_services": ["angular"]
        "angular-restmod-style": ["angular-restmod", "angular-restmod-plus-preload", "angular-restmod-plus-dirty"]
        "angular-restmod-plus-preload": ["angular-restmod", "lodash"]
        "angular-restmod-plus-dirty": ["angular-restmod", "lodash"]
        "ngTagsInput": ["angular"]
        "promise": ["angular"]
        "ngload": ["angularAMD"]
        "bootstrap": ["angular"]
        "jquery-ui": ["jquery"]
        "slimscroll": ["jquery"]
        "angular-dragdrop": ["angular", "jquery-ui"]
        "chinaMap": ["jquery", "Raphael", "angular"]
        "ngDraggable": ["angular"]
        "hightGallery-thumbnail": ["hightGallery"]
        "hightGallery-fullscreen": ["hightGallery"]
        "angular-select-ui": ["angular", "angular-sanitize"]
        "Program_Model": ["Model_factory", "Program_Fields"]
        "Program_Directive": ["Program_Model"]
        "Program_Factory": ["Model_factory", "Program_Fields", "Program_Model"]
        "highcharts-ng": ["highcharts", "angular"]
        "ng-file-upload": ["angular"]
        "angular-clipboard": ["angular"]
        "textAngular-rangy": ["angular"]
        "textAngular-sanitize": ["textAngular-rangy"]
        "textAngular": ["textAngular-sanitize"]
        "ngWYSIWYG": ["angular"]
    },
    deps: ["app"]
})
