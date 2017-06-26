'use strict';
define(['angularAMD'], (angularAMD)->
    angularAMD
        .factory('Users', [
        '$http', '$localStorage', 'SiteConfig'
        ($http, $localStorage, SiteConfig)->
            user = {}
            transform = (data)->
                return $.param(data)
            deset = (name, item)->
                user[name] = (data, successCallBack, error, resetUrl)->
                    if typeof error is 'undefined'
                        error = angular.copy(successCallBack)
                        successCallBack = data and angular.copy(data)
                        data = {}
                    $http[item.method](resetUrl || item.url, data)
                        .success(successCallBack).error(error)
            for name,item of angularAMD.deurl.user
                deset(name, item)
            user.logout = (success, error)->
                if SiteConfig.authMethod is 'token'
                    delete $localStorage.authorization
                    delete $localStorage.historyNav
                else
                    user.signout(success, error)
                success()
            user
    ])# English, Español, 日本語, 中文, Deutsch, français, Italiano, Portugal, Русский язык, 한국어
# English:          EN-US
# Spanish:          Español ES-ES
# Japanese:         日本語 JA-JP
# Chinese:          简体中文 ZH-CN
# Chinese:          繁体中文 ZH-TW
# German:           Deutsch DE-DE
# French:           français FR-FR
# Italian:          Italiano IT-IT
# Portugal:         Portugal PT-BR
# Russian:          Русский язык RU-RU
# Korean:           한국어 KO-KR

# thanks for the icons: https://www.iconfinder.com/search/?q=iconset%3Aflags_gosquared

        .factory('localize', [
        '$http', '$rootScope', '$window'
        ($http, $rootScope, $window) ->
            localize =
                language: ''                    # use the $window service to get the language of the user's browser
                url: undefined                  # location of the resource file
                resourceFileLoaded: false       # flag to indicate if the service has loaded the resource file

                successCallback: (data) ->
                    localize.dictionary = data
                    localize.resourceFileLoaded = true
                    $rootScope.$broadcast('localizeResourcesUpdated')

                setLanguage: (value) ->
                    localize.language = value.toLowerCase().split("-")[0]
                    localize.initLocalizedResources()

                setUrl: (value) ->
                    localize.url = value
                    localize.initLocalizedResources()

                buildUrl: ->
                    if !localize.language
# window.navigator.userLanguage is IE only, and window.navigator.language for the rest.
                        localize.language = ($window.navigator.userLanguage || $window.navigator.language).toLowerCase()
                        localize.language = localize.language.split("-")[0] # get just the language for now
                    return 'i18n/resources-locale_' + localize.language + '.js'

# loads the language resource file from the server
                initLocalizedResources: ->
                    url = localize.url || localize.buildUrl()

                    $http({method: "GET", url: url, cache: false})
                        .success(localize.successCallback)
                        .error(->
                        $rootScope.$broadcast('localizeResourcesUpdated')
                    )

                getLocalizedString: (value) ->
                    result = undefined
                    if (localize.dictionary && value)
                        valueLowerCase = value.toLowerCase()
                        if localize.dictionary[valueLowerCase] is ''
                            result = value
                        else
                            result = localize.dictionary[valueLowerCase]
                    else
                        result = value

                    return result

            # localize on init, for auto l18n and l10n
            # localize.initLocalizedResources()

            return localize
    ])
        .factory('ngWebSocket', [
        '$rootScope'
        'logger'
        ($rootScope, logger)->
            (url, log, open, callback, close, f)->
                $rootScope.WebSocket = {}
                if !window.WebSocket then return alert('当前浏览器不支持WebSocket,请更新IE9以上或者其他新版浏览器.')
                try
                    ws = new WebSocket(url)
                    ws.onopen = (e)->
                        open(e, ws, f)
                        logger.logSuccess(log + '->连接成功')
                    ws.onmessage = (e)->
                        results = JSON.parse(e.data).results
                        callback(results, ws, f, e)
                    ws.onclose = (e)->
                        logger.logError(log + '->断开连接')
                        close(e, url, log, open, callback, close, f)
                    ws.onerror = (e)->
                        logger.logError(log + '->请求错误')
                catch e
                    return
    ])
        .factory('baseController', ($localStorage, $location)->
        (model)->
            if $localStorage.historyNav? and $localStorage.historyNav.url.match(/^\/[^\/]*/).length isnt 0 and $localStorage.historyNav.url.match(/^\/[^\/]*/)[0] is $location.path().match(/^\/[^\/]*/)[0]
                @pageTitle = $localStorage.historyNav.text
                @pageIcon = $localStorage.historyNav.icon
            else
                @pageTitle = $(document).find('[href="#' + $location.path() + '"]').text().replace(/\s+/g, '')
            @config = {}
            @config.model = model
            @config.plus =
                edit: true
                delete: true
            @config.init = (scope)->
                scope.tableConfigure =
                    allowAdd:
                        val: true
                        shown: true
                        name: "新增"
                    tdFocus:
                        val: true
                        shown: true
                        name: "焦点"
                    columnDrop:
                        val: true
                        shown: true
                        name: "单列拖拽"
                scope
            @config.edit = (scope)->
                scope
            @
    )
        .factory('simpleRequest', (logger)->
        (http, word, fn)->
            _.map [['Success', '成功'], ['Error', '失败']], (i)->
                http = http[i[0].toLowerCase()](->
                    fn()
                    logger["log#{i[0]}"]("#{word}#{i[1]}")
                )
    )
        .filter('numberFilter', ()->
        (input)->
            parseFloat(input).toLocaleString()
    )
)
