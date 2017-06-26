define(['app','logger'],->
    ['$scope','$localStorage','$location','Users','logger'
        ($scope,$localStorage,$location,Users,logger)->
            $scope.signup = ->
                formData = {
                    email: $scope.email,
                    password: $scope.password,
                    realname:$scope.realname
                }
                Users.signup(formData,(res)->
                    if res.type is false
                        logger.logError(res.data)
                    else
                        $localStorage.token = res.data.token
                        $scope.$emit('reload-user',res);
                        $location.path('/')
                ,
                    ->logger.logError('Failed to signup')
                )
            $scope.me = ->
                Users.me((res)->
                    $scope.myDetails = res
                ,
                    ->logger.logError('Failed to Give Userinfo')
                )
    ]
)
