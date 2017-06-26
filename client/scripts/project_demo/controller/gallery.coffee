'use strict';
define(["app","common","angular-resource","hightGallery","hightGallery-thumbnail","hightGallery-fullscreen"],->
  [
    '$scope', '$filter','$http'
    ($scope, $filter,$http) ->
# filter
      $scope.config={}
      $scope.config.url = '{domain}/other/product'
      $scope.config.sizelist = [12,18,24,30]
      $scope.config.viewDetail = (store)->
        $http.get('{domain}/other/detail?product='+store._id).success(
            (detail)->
                dynamicEl = []
                for item in detail.data
                    dynamicEl.push(
                        {
                            src:'http://127.0.0.1:3003/'+item.local,
                            thumb:'http://127.0.0.1:3003/'+item.thumbnail_local
                            subHtml:'<p>'+store.title+'</p>'+'<p>尺寸:'+item.width+'*'+item.height+'</p>'
                        }
                    )
                $('#'+store._id).lightGallery(
                    {
                        loop:false
                        escKey:true
                        dynamic: true
                        hideBarsDelay:2000
                        dynamicEl:dynamicEl
                    }
                )
                $scope.config.detailView = detail.data
        )
  ])
