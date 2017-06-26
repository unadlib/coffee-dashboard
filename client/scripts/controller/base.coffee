'use strict';
arr = ["app","common","datatable"]
if window.angularIsModule then arr.push('ng-file-upload','ng-img-crop')
define(arr,->
    moduleName = window.location.hash.replace('#/','')
    fName = if window.angularIsModule then 'fPublicFactory' else 'f'+_.cInitial(moduleName) #非自定义时,公共基本model,fModel规则
    [
        '$scope','baseController','$injector',fName
        ($scope,baseController,$injector,fFactory) ->
            str = location.hash.replace('#/','')
            moduleName = window.location.hash.replace('#/','')
            factory = if window.angularIsModule then fFactory(str) else $injector.get('f'+_.cInitial(moduleName))
            baseController.call $scope,factory #引用baseController基本model逻辑与配置
    ])

