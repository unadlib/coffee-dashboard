'use strict';
define(["app","common","datatable","hightGallery","hightGallery-thumbnail","hightGallery-fullscreen"],->
    [
        '$scope', '$filter','$http'
        ($scope, $filter,$http) ->
            $scope.config={}
            $scope.config.url = '{domain}/other/product'
            $scope.config.fields = [
                {
                    name:'title'
                    text:'标题'
                    type:'string'
                    show:true
                    link:false
                    sort:true
                    required:true
                }
                {
                    name:'cat'
                    text:'分类'
                    type:'select'
                    show:true
                    link:false
                    sort:true
                    select:{url:'{domain}/other/cat',key:'_id',value:'title'}
                    required:true
                }
                {
                    name:'tags'
                    text:'标签'
                    type:'tags'
                    show:true
                    link:false
                    sort:true
                    required:true
                }
                {
                    name:'time'
                    text:'日期'
                    type:'date'
                    show:true
                    link:false
                    sort:true
                    required:true
                }
            ]
            $scope.config.search = [
                {
                    name:'search'
                    text:'搜索'
                    type:'string'
                }
                {
                    name:'label'
                    text:'顶级分类'
                    type:'select'
                    select:{url:'{domain}/other/label',key:'_id',value:'title'}
                }
                {
                    name:'cat'
                    text:'上级分类'
                    type:'select'
                    relation:'label'
                    select:{url:'{domain}/other/cat',key:'_id',value:'title'}
                }
                {
                    name:'date'
                    text:'区域时间'
                    type:'daterange'
                }
                {
                    name:'button'
                    text:'查询'
                    type:'button'
                }
            ]
            $scope.config.plus = {
                edit:true
                delete:true
                viewGallery:true
            }
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
