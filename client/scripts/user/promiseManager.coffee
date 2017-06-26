'use strict';
define(["app","common","datatable"],->
  [
    '$scope', '$filter','sPromise'
    ($scope, $filter,sPromise) ->
      $scope.config={}
      $scope.config.model = sPromise
      $scope.config.plus = {
        edit:true
        delete:true
      }
  ])
