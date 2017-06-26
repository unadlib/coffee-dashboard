define(['app','logger'],->
    ['$scope','$localStorage','$location','Users','SiteConfig','logger','$compile'
        ($scope,$localStorage,$location,Users,SiteConfig,logger,$compile)->
            if SiteConfig.authMethod is "cookie" and SiteConfig.cookie
                $(document).find('.page-signin').hide().after("""
                    <div class="loading-modal">
                        <div class="loading">
                            <div class="spinner">
                                <div class="bounce1"></div>
                                <div class="bounce2"></div>
                                <div class="bounce3"></div>
                            </div>
                        </div>
                    </div>
                """)
            SiteConfig.initLogin and SiteConfig.initLogin($scope,$compile)
            $scope.signin = ->
                formData = {
                    email: $scope.username,
                    username: $scope.username,
                    password: $scope.password
                }
                SiteConfig.beforeLogin and SiteConfig.beforeLogin($scope,formData)
                Users.signin(formData,(res)->
                    SiteConfig.afterLogin and SiteConfig.afterLogin($scope,res,$localStorage)
                    if res.type is false
                        logger.logError(res.data)
                    else
                        #if SiteConfig.authMethod is 'token'
                        #    $localStorage.token = res.data.token
                        #$scope.$emit('reload-user',res);
                        #$location.path('/')
                        window.location = '.'
                ,
                    ->logger.logError('登陆失败')
                )
            $scope.me = ->
                Users.me((res)->
                    $scope.myDetails = res
                ,
                    ->logger.logError('获取个人信息失败')
                )
    ]
)
