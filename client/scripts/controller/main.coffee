'use strict';
define(['angularAMD'],(angularAMD)->
    # overall control
    angularAMD.controller('AppCtrl', [
        '$scope', '$rootScope','$location','$localStorage','$document','$element','$uibModal','Users','localize','SiteConfig','$compile','$http','$injector'
        ($scope, $rootScope,$location,$localStorage,$document,$element,$uibModal,Users,localize,SiteConfig,$compile,$http,$injector) ->
            cookieLogout = ->
                if SiteConfig.authMethod is "cookie" and SiteConfig.cookie and SiteConfig.cookie.login
                    delete $localStorage.historyNav
                    window.location.href = SiteConfig.cookie.login
                    return 'logout'
            $scope.main = angularAMD.main
            $scope.pageTransitionOpts = angularAMD.pageTransitionOpts
            $scope.admin = angularAMD.admin
            $scope.loadsetting =false;
            $scope.locationAction = ->
                lo = ''
                for item in $location.path().split('/')
                    out = []
                    if item is ''
                        out.push({text:'Home',link:'/'})
                    else
                        lo = lo+item
                        out.push({text:item,link:lo})
                    out
            settingRouter = (pro_res)->
                for x in pro_res.results
                    if _.isArray(x.child) and x.child.length is 0 then delete x.child
                SiteConfig.initRouter(pro_res.results,true)
                $scope.route  = pro_res.results
                $scope.$broadcast('reload-nav',pro_res.results)
                url = ''
                for i in pro_res.results
                    if i.isShow is false or ( _.isArray(i.child) and i.child.length is 0 )then continue
                    if _.isArray(i.child) and i.child.length > 0
                        for t in i.child
                            if t.isShow is false then continue
                            if url.length is 0 then url = t.url
                        continue
                    if url.length > 0 then break
                    url = i.url
                    break

                if $localStorage.historyNav then url = $localStorage.historyNav.url
#                url = if pro_res.results[0].child then pro_res.results[0].child[0].url else pro_res.results[0].url
                SiteConfig.routeProvider
                .when('/', { redirectTo:url} )
                .otherwise( redirectTo: '/404' )
                if path() is SiteConfig.getRouter('signin').url
                    $location.path('/')

            $scope.location = $scope.locationAction()

            $scope.reset = (res)->
                $scope.main = res
                $rootScope.userinfo = res
                $scope.main.brand = angularAMD.main.brand
                $scope.loadsetting = true
                if !res.data || !res.data.setting
                    res.data = {} if !res.data or typeof res.data isnt 'object' #标记
                    res.data.setting = angularAMD.setting || angularAMD.admin
                $scope.admin = res.data.setting
                if angularAMD.userKey and !$scope.main.data.realname
                    arr = angularAMD.userKey.split('.')
                    if arr.length == 1
                        $scope.main.data.realname = $scope.main[arr[0]]
                    if arr.length == 2
                        $scope.main.data.realname = $scope.main[arr[0]][arr[1]]
                $scope.setLang($scope.admin.lang)
                Users.promise('',settingRouter,(->console.log('promise error')),angularAMD.afterPromise)

            $scope.$on('reload-user',(event,res)->
                $scope.reset(res)
            )
            $scope.$on('location',(event,res)->
                $scope.location = $scope.locationAction()
            )
            $scope.logout = ->
                Users.logout(->
                    if cookieLogout() is 'logout' then return
                    $location.path(SiteConfig.getRouter('signin').url )
                ,
                    ->
                )
            $scope.lock = ->
                Users.lock(->
                    $location.path(SiteConfig.getRouter('lock-screen').url)
                ,
                    ->$location.path(SiteConfig.getRouter('lock-screen').url)
                )
            $scope.changePassword = ->
                if angularAMD.changePSW
                    return $injector.get(angularAMD.changePSW)(angularAMD.userInfo.manager)#自定义修改密码
                modalInstance = $uibModal.open(
                    templateUrl: "views/user/ch-password.html"
                    controller: 'passwordCtrl'
                )
            $scope.start = ->
                Users.me((res)->
                    angularAMD.userInfo = res
                    angularAMD.beforeInit($scope,$compile,$http,$rootScope) if angularAMD.beforeInit
                    $scope.reset(res)
                    angularAMD.afterInit($scope,$compile,$http,$rootScope) if angularAMD.afterInit
                ,->
                    cookieLogout()
                )
            pa = ->
            switch $location.path()
                when SiteConfig.getRouter('signup').url then pa()
                when SiteConfig.getRouter('forgot-password').url then pa()
                else $scope.start()


            $scope.savesetting = ->
                if $scope.admin.server is true
                    Users.setting($scope.admin,->
                        console.log('save Successfull...');
                    ,
                        ->console.log('oh no...')
                    )
            path = ->
                return $location.path()

            addBg = (path) ->
            # remove all the classes
                $element.removeClass('body-wide body-lock')
                # add certain class based on path
                for item in SiteConfig.routerRoot
                    if item.wide is true and path is item.url
                        $element.addClass('body-wide')
                        break

                switch path
                    when SiteConfig.getRouter('lock-screen').url then $element.addClass('body-wide body-lock')

            addBg( $location.path() )

            $scope.$watch(path, (newVal, oldVal) ->
                if newVal is oldVal
                    return
                $scope.locationAction()
                addBg($location.path())
            )
            $scope.getRouter = SiteConfig.getRouter

            $scope.$watch('admin', (newVal, oldVal) ->
                if newVal.menu is 'horizontal' && oldVal.menu is 'vertical'
                    $rootScope.$broadcast('nav:reset')
                    return $scope.savesetting()
                if newVal.fixedHeader is false && newVal.fixedSidebar is true
                    if oldVal.fixedHeader is false && oldVal.fixedSidebar is false
                        $scope.admin.fixedHeader = true
                        $scope.admin.fixedSidebar = true
                    if oldVal.fixedHeader is true && oldVal.fixedSidebar is true
                        $scope.admin.fixedHeader = false
                        $scope.admin.fixedSidebar = false
                    return $scope.savesetting()
                if newVal.fixedSidebar is true
                    $scope.admin.fixedHeader = true
                if newVal.fixedHeader is false
                    $scope.admin.fixedSidebar = false
                $scope.savesetting()
            , true)
            $scope.setLang = (lang) ->
                localize.setLanguage(angularAMD.lang[lang].file);
                $scope.admin.lang = lang
            $scope.getFlag = () ->
                lang = $scope.admin.lang
                angularAMD.lang[lang].class
            $scope.color = angularAMD.color
            $scope.setLang($scope.admin.lang)

    ])
    .controller('HeaderCtrl', [
        '$scope'
        ($scope) ->
            $scope
    ])
    .controller('NavContainerCtrl', [
        '$scope'
        ($scope) ->
            $scope
    ])
    .controller('NavCtrl', [
        '$scope','$rootScope', 'filterFilter','$location','$element','$timeout','$localStorage','$route'
        ($scope,$rootScope, filterFilter,$location,$element,$timeout,$localStorage,$route) ->
            $scope.nav = []
            iniState = ()->
                $window = $(window)
                $app = $('#app')
                $nav = $('#nav-container')
                $lists = $element.find('ul').parent('li') # only target li that has sub ul
                $lists.append('<i class="fa fa-angle-down icon-has-ul-h"></i><i class="fa fa-angle-right icon-has-ul"></i>')
                $a = $lists.children('a')
                $listsRest = $element.children('li').not($lists)
                $aRest = $listsRest.children('a')
                $a.on('click', (event) ->
                    event.preventDefault()
                    if ( $app.hasClass('nav-collapsed-min') || ($nav.hasClass('nav-horizontal') && $window.width() >= 768) ) then return false
                    $this = $(this)
                    $parent = $this.parent('li')
                    !angularAMD.navShowAll and $lists.not( $parent ).removeClass('open').find('ul').slideUp()
                    !angularAMD.navShowAll and $parent.toggleClass('open').find('ul').slideToggle()
                )
                $aRest.on('click', (event) ->
                    !angularAMD.navShowAll and $lists.removeClass('open').find('ul').slideUp()
                )
                $scope.$on('nav:reset', (event) ->
                    !angularAMD.navShowAll and $lists.removeClass('open').find('ul').slideUp()
                )
                Timer = undefined
                prevWidth = $window.width()
                updateClass = ->
                    currentWidth = $window.width()
                    if currentWidth < 768 then $app.removeClass('nav-collapsed-min')
                    if prevWidth < 768 && currentWidth >= 768 && $nav.hasClass('nav-horizontal')
                        !angularAMD.navShowAll and $lists.removeClass('open').find('ul').slideUp()
                    prevWidth = currentWidth
                $window.resize( () ->
                    clearTimeout(t)
                    t = setTimeout(updateClass, 300)
                )
                setTimeout ->#刷新页面恢复菜单状态
                    if $(document).find('#nav a').size() is 0 then return false
                    for i in $(document).find('#nav a')
                        url = $(i).attr('href').replace '#',''
                        if ( $localStorage.historyNav and $localStorage.historyNav.url is url) or $location.path() is url
                            if $(i).parents().eq(1).attr('id') is 'nav'
                                $(i)
                                .parent()
                                .addClass('active')
                            else
                                $(i)
                                .parent()
                                .addClass('active')
                                .parent()
                                .parent()
                                .addClass('open')
                                if !!$(document).find('.nav-vertical').size() then $(i).parent().parent().show()
                ,50
                angularAMD.navUserDefined and angularAMD.navUserDefined()

            $scope.$on('reload-nav',(event,res)->
                if angularAMD.nav?
                    _.map res,(n)->
                        for i,j of angularAMD.nav
                            if i is 'child'
                                _.map n[j],(m)->
                                    for k,l of angularAMD.nav
                                        m[k]=m[l]
                            n[i]=n[j]
                $localStorage.allNav = res
                $scope.nav=res
                $timeout(iniState
                ,0)
            )
            $scope.local = $location.path()
            links = $element.find('a')
            path = () ->
                return $location.path()
            $scope.historyNav = (item,event)->
              if '#'+item.url is window.location.hash #点击当前nav->刷新
                $route.reload()
              if item.child? then return false
              $localStorage.historyNav = item
            $scope.$watch(path, (newVal, oldVal) ->
                if newVal is oldVal
                    return
                #添加手机上自动缩合
                app = $('#app')
                app.removeClass('on-canvas')
                $scope.$emit('location',true)
                angular.forEach($element.find('a'),(link)->
                    $link = angular.element(link)
                    $li = $link.parent('li')
                    href = $link.attr('href')
                    if ($li.hasClass('active'))
                        $li.removeClass('active')
                    if href == "##{$location.path()}"
                        $li.addClass('active')
                )
            )

    ])
    .controller('passwordCtrl',['$scope','$uibModalInstance','$interval','Users'
        ($scope,$uibModalInstance,$interval,Users)->
            $scope.cancel = ->
                $uibModalInstance.dismiss "cancel"
                return
            $scope.alert = {
                'type':'info'
                'show':false
                'message':'wall'
            }
            setMessage = (type,message,show)->
                $scope.alert.type=type
                $scope.alert.message=message
                $scope.alert.show = show
            time = 5
            startRelogin = (mess)->
                time = time-1
                $scope.alert.message = pubmessage+'，'+time+'秒后重新登录'
                if time is 0
                    window.location = '/'

            pubmessage = ''
            field =
                n:'newPwd'
                o:'oldPwd'
            $scope.fields = angularAMD.PSW or field
            $scope.submit = ->
                Users.chpasswd($scope.user,(res)->
                    type = 'success'
                    pubmessage = res.message or '修改成功'
                    $interval(startRelogin,1000)
                    setMessage(type,res.message,true)
                ,(res)->
                    message = if res.message? then res.message else '未知网络错误'
                    setMessage('danger',message,true)
                )
    ])
    return angularAMD
)
