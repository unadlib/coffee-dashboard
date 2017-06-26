define(['app','logger'],->
    ['$scope','$localStorage','$location','Users','logger'
        ($scope,$localStorage,$location,Users,logger)->
            $scope.unlock = ->
                formData = {
                    password: $scope.password
                    email:$scope.email
                }
                Users.unlock(formData,(res)->
                    if res.type is false
                        return logger.logError(res.data)
                    else
                        $location.path('/')
                ,
                    ->logger.logError('Failed to unlock-screen')
                )
            $scope.token = $localStorage.token
    ]
)
