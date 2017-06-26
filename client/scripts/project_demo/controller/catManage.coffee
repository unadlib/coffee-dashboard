'use strict';
define(["app","common","datatable",'chinaMap'],->
  [
    '$scope', '$filter','fCat'
    ($scope, $filter,fCat) ->
      $scope.config = {}
      $scope.config.model = fCat
      $scope.config.plus = {
        edit:true
        delete:true
      }
      $scope.config.init = (scope)->
        scope
      $scope.data = {showlist:true}
      $scope.data.stateData = [
        {name:'福建',value:366},
        {name:'海南',value:5451},
        {name:'广东',value:1212},
        {name:'上海',value:851}
      ]



  ])
