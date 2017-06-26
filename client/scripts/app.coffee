define(['common'
    'config'
    'Model_services'
    'Program_Model'
    'Program_Directive'
    'Program_Factory'
    'sysDirectives'
    'sysFactory'
    'sysController'
    'ngDraggable'
    'angular-select-ui'
    'angular-clipboard'
    'ngWYSIWYG'
],
    (angularAMD)->
        app = angular.module('app', [
            'ngRoute'
            'ngAnimate'
            'ui.bootstrap'
            'ngStorage'
            'ngDraggable'
            'restmod'
            'ngTagsInput'
            'ngSanitize'
            'ui.select'
            'angular-clipboard'
            'ngWYSIWYG'
        ])
            .config([
            '$routeProvider', '$httpProvider', '$provide', 'restmodProvider', '$compileProvider'
            ($routeProvider, $httpProvider, $provide, restmodProvider, $compileProvider) ->
                $compileProvider.debugInfoEnabled(false)
                routes = []
                publicRouter = angularAMD.publicRouter
                prefix2string = (s)->
                    s = s.split('/')
                    for key,val of s
                        if val.indexOf(':') >= 0
                            s.splice(key, 1)
                    s.join('/')
                getRouter = (name)->
                    for item in publicRouter
                        if item.name is name
                            return item
                setRoutes = (route, isremote, fullField) ->
                    url = route
                    prefix = if isremote and angularAMD.prefix then '/' + angularAMD.prefix else ''
                    other = if isremote is true then '/controller' else ''
                    if route is '/user/promiseManager'
                        other = ''
                    config =
                        templateUrl: 'views' + (if fullField? and fullField.html_defined == false then '/base' else prefix + prefix2string(route)) + '.html'
                        controllerUrl: 'scripts' + (if fullField? and fullField.js_defined == false then '/controller/base' else  prefix + other + prefix2string(route)) + '.js'
                    config = angularAMD.setRoute(config, fullField) if angularAMD.setRoute
                    prefix2string(route)
                    $routeProvider.when(url, angularAMD.route(config))
                    return $routeProvider
                initRouter = (ru, isremote)->
#                    if ru and ru.length > 0
#                        window.localStorage['ngStorage-allNav'] = JSON.stringify(ru)
#                    if ru.length is 0 and JSON.parse(window.localStorage['ngStorage-allNav']).length > 0
#                          ru = JSON.parse(window.localStorage['ngStorage-allNav'])
                    ru.forEach((route)->
                        if !!route.child
                            route.child.forEach((e)->
                                setRoutes(e.url, true, e)
                            )
                        else
                            setRoutes(route.url, isremote, route)
                    )
                    if ru.length is 0
                        alert '登陆账户无任何权限'
                        if angularAMD.authMethod is "cookie" and angularAMD.cookie and angularAMD.cookie.login
                            window.location.href = angularAMD.cookie.login
                            return
                    $routeProvider
                        .otherwise(redirectTo: ru[0].url)
                if angular.isUndefined(window.localStorage['ngStorage-historyNav']) is false
                    historyNav = JSON.parse(window.localStorage['ngStorage-historyNav'])
                    initRouter([historyNav], true)
                    $routeProvider.otherwise(redirectTo: historyNav.url)
                initRouter(publicRouter, false)
                $provide.factory('SiteConfig', ->
                    obj =
                        route: routes
                        publicRouter: publicRouter
                        routerRoot: routes.concat(publicRouter)
                        getRouter: getRouter
                        setRoutes: setRoutes
                        routeProvider: $routeProvider
                        initRouter: initRouter
                        authMethod: angularAMD.authMethod
                        cookie: angularAMD.cookie
                    angularAMD.customization and angular.extend obj, angularAMD.customization #自定义设置
                    obj
                )
                $provide.factory('timestampMarker', ['$rootScope'
                    ($rootScope)->
                        timestampMarker = {
                            request: (config)->
                                $rootScope.loading = true
                                config.requestTimestamp = new Date().getTime()
                                config
                            response: (response)->
                                $rootScope.loading = false
                                response.config.responseTimestamp = new Date().getTime()
                                response
                        }
                ])
                angularAMD.getFactory = (name, callback)-> $provide.factory(name, callback) #动态Factory
                $httpProvider.defaults.headers.common["X-Requested-With"] = 'XMLHttpRequest'
                $httpProvider.defaults.headers.common["Ng-Ajax"] = 'true'
                $httpProvider.defaults.timeout = angularAMD.timeout or 1000 * 120
                $httpProvider.interceptors.push('timestampMarker')
                restmodProvider.rebase('AMSApi')
                removeLoading = (response)->
                    if response.config? and response.config.params? and response.config.params._?
                        $(document)
                            .find('[loading_id=' + response.config.params._ + ']')
                            .removeAttr('loading_id')
                            .find('.loading-spinner')
                            .remove()
                $httpProvider.interceptors.push([
                    '$q', '$location', '$localStorage', '$rootScope'
                    ($q, $location, $localStorage, $rootScope)->
                        {
                            'request': (config)->
                                isProject = new RegExp("views\/" + window.project)
                                if isProject.test(config.url) and !/\/(edit|table)\//.test(config.url) and $rootScope.WebSocket
                                    for i,j of $rootScope.WebSocket
                                        if j and j.close then j.close()
                                if /\/api\/task/.test(config.url) and $rootScope.IntervalFn and $(document).find('.edit-taskList').size() is 0 #清除dmp定时刷新任务结果
                                    clearInterval $rootScope.IntervalFn

                                if typeof config.params isnt 'undefined'
                                    for key,value of config.params
                                        if key is '_'
                                            $(document).find('[loading_id=' + config.params[key] + ']').append(angularAMD.loadingHTML)
                                        if value is ''
                                            delete config.params[key]
                                if config.url.indexOf('{domain}') >= 0
                                    config.url = config.url.replace('{domain}', angularAMD.domian)
                                config.headers = config.headers or {}
                                if $localStorage.authorization && angularAMD.authMethod is 'token' #header token
                                    config.headers.Authorization = 'Bearer ' + $localStorage.authorization
                                if $localStorage.token && angularAMD.authMethod is 'token' #body token
                                    config.headers.Authorization = 'Bearer ' + $localStorage.token.access_token
                                config
                            'responseError': (response)->
                                removeLoading response
                                if response.status is 401 or response.status is 403 or response.status is 0
                                    $location.path(getRouter('signin').url)
                                if response.status is 423
                                    $location.path(getRouter('lock-screen').url)
                                $q.reject(response)
                            'response': (response)->
                                removeLoading response
                                angularAMD.afterResponse and angularAMD.afterResponse(response)
                                if response.headers('authorization') isnt null
                                    delete $localStorage.authorization
                                    $localStorage.authorization = response.headers('authorization')
                                response
                        }
                ])
        ])
        angularAMD.bootstrap(app)
)
