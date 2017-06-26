define(['angularAMD'],(angularAMD)->

    angularAMD.directive('imgHolder', [ ->
        return {
            restrict: 'A'
            link: (scope, ele, attrs) ->
                Holder.run(
                    images: ele[0]
                )
        }
    ])
    #弹窗上传
    .directive('uploadModal',[
        ->
            restrict: "EA"
            require: '^ngModel'
            scope:
                ngModel: '='
                uploadConfig:'='
                uploadModal: '='
            controller: ['$scope', '$element','$uibModal'
                ($scope, $element,$uibModal) ->
                    $element.on('click', ->
                        parentField = $element.attr('feild-parent')
                        $scope.data = if parentField then $scope.ngModel[parentField][$scope.uploadModal] else $scope.ngModel[$scope.uploadModal]
                        modalInstance = $uibModal.open(
                            template:->
                                """
                                    <form name="form_constraints" class="form-validation uploadModal" novalidate>
                                        <section class="panel-default">
                                            <div class="panel-heading" id='upLoadAdMaterials'>
                                                <strong><span class="glyphicon glyphicon-th"></span>{{store.$pk?'编辑上传:'+store.$pk:'新增上传'}}</strong>
                                                <div class="pull-right">
                                                    <span class="glyphicon glyphicon-remove" ng-click="close()"></span>
                                                </div>
                                            </div>
                                            <div class="panel-body">
                                                <div class="row">

                                                    <div class="col-md-12" style="padding: 10px;">
                                                        <form>
                                                                <div ngf-select=""
                                                                     ngf-drop=""
                                                                     ng-model="upLoadFile"
                                                                     style="min-height:110px;height:auto;"
                                                                     class="drop-box"
                                                                     ngf-accept="config.uploadType"
                                                                     ngf-pattern="config.uploadType"
                                                                     ngf-drop-available="dropAvailable">
                                                                        <span ng-if="upLoadFile.$error">
                                                                            {{upLoadFile.$error}}
                                                                        </span>
                                                                        <span ng-if="upLoadFile.$errorParam">
                                                                            {{upLoadFile.$errorParam}}
                                                                        </span>
                                                                        <img ngf-src="upLoadFile" style="max-width:540px;" ng-if="upLoadFile"  class="thumb">
                                                                        <img ng-if="items.url&&!upLoadFile" style="max-width:540px;" ng-src="{{items.url}}" />
                                                                        <span ng-if="!upLoadFile.name&&!items.url"
                                                                              ng-bind-html="config.uploadRender?config.uploadRender():'请上传文件'"></span>
                                                                        <span style="line-height: 40px;" ng-if="upLoadFile.name&&!upLoadFile.$error&&!upLoadFile.$error">
                                                                            {{upLoadFile.name}}({{(upLoadFile.size/1024)|number:2}}K)
                                                                        </span>
                                                                </div>
                                                        </form>
                                                    </div>
                                                    <div class="col-md-12">
                                                        <uib-progressbar class="progressbar-sm progress-rounded progress-striped ng-hide"
                                                                         ng-show="upLoadFile&&upLoadFile.progress >= 0"
                                                                         value="upLoadFile.progress"
                                                                         type="success">{{upLoadFile.progress+'%'}}</uib-progressbar>
                                                    </div>


                                                </div>
                                            </div>
                                            <div class="panel-footer">
                                                <button type="button" ng-click="upload(upLoadFile)" class="btn btn-success btn-w-md" ng-class="{'btn-loading':!isAbort}" data-ng-disabled="!upLoadFile">确定上传并保存</button>
                                                <button type="button" class="btn btn-danger" ng-click="items.url=null;upLoadFile=null;"><i class="fa fa-trash"></i></button>
                                                <button type="button" class="btn btn-default" ng-click="reset()">重置</button>
                                                <button type="button" class="btn btn-danger" ng-click="abort()" data-ng-hide="isAbort">取消上传</button>
                                                <div class="pull-right">
                                                    <button type='button' class="btn btn-warning btn-w-md" ng-click="close()">关闭</button>
                                                </div>
                                            </div>
                                        </section>
                                    </form>
                                    <style>.uploadModal .drop-box span{display:block !important;}</style>
                                """
                            controller: ['$scope','items','$uibModalInstance','logger','Upload'
                                ($scope,items,$uibModalInstance,logger,Upload)->
                                    $scope.items = angular.copy items
                                    $scope.config = items.config or _.where($scope.items.store.$field,name:$scope.items.key)[0]
                                    $scope.isAbort = true
                                    $scope.reset = ->
                                        $scope.upLoadFile = null
                                        $scope.isAbort = true
                                        $scope.items = angular.copy items
                                        $scope.upLoadAction.abort() if $scope.upLoadAction
                                    $scope.upload = (file) ->
                                        uploadData = {}
                                        uploadData[$scope.config.uploadFile] = file
                                        file.upload = Upload.upload(
                                            url: $scope.config.uploadUrl
                                            data:uploadData
                                        )
                                        file.upload.then((response) ->
                                            setTimeout ->
                                                $scope.isAbort = true
                                                file.result = response.data
                                                $uibModalInstance.close({data:response.data[$scope.config.uploadResult],config:$scope.config})
                                                logger.logSuccess('上传成功')
                                            ,0
                                        ,(res) ->
                                            $scope.isAbort = true
                                            if res.data then logger.logError(if res.data.message then res.data.message else '上传失败')
                                        ,(evt) ->
                                            $scope.isAbort = false
                                            file.progress = Math.min(100, parseInt(100.0 * evt.loaded / evt.total))
                                        )
                                        $scope.upLoadAction = file.upload
                                        return
                                    $scope.abort = ->
                                        $scope.isAbort = true
                                        $scope.upLoadAction.abort()

                                    $scope.close = ->
                                        $uibModalInstance.dismiss "cancel"
                                    setTimeout ->
                                        $('.modal-dialog').draggable({handle: '#upLoadAdMaterials.panel-heading'})
                                    ,0
                            ]
                            resolve: items: ->
                                store:$scope.ngModel
                                url:$scope.data
                                key:$scope.uploadModal
                                config:$scope.uploadConfig
                        )
                        modalInstance.result.then (d)->
                            data = d.data
                            data = (if !d.config.unCompletion then (window.location.origin+'/media/') else '')+data
                            data = (if d.config.uploadPrefix then d.config.uploadPrefix else '')+data
                            if parentField
                                $scope.ngModel[parentField][$scope.uploadModal] = data
                            else
                                $scope.ngModel[$scope.uploadModal] = data
                        ,->



                    )
            ]
    ])
    #树状
    .directive( 'treeModel',
        ['$compile',
        ($compile)->
            restrict: 'A',
            link: (scope, element, attrs)->
                treeId = attrs.treeId
                treeModel = attrs.treeModel
                nodeId = attrs.nodeId or 'id'
                nodeLabel = attrs.nodeLabel or 'label'
                nodeChildren = attrs.nodeChildren or 'children'
                template = '<ul><li data-ng-repeat="node in ' + treeModel + '"><i class="collapsed" data-ng-show="node.' + nodeChildren + '.length && node.collapsed" data-ng-click="' + treeId + '.selectNodeHead(node)"></i><i class="expanded" data-ng-show="node.' + nodeChildren + '.length && !node.collapsed" data-ng-click="' + treeId + '.selectNodeHead(node)"></i><i class="normal" data-ng-hide="node.' + nodeChildren + '.length"></i> <span data-ng-class="node.selected" data-ng-click="' + treeId + '.selectNodeLabel(node)">{{node.' + nodeLabel + '}}</span><span class="ng-hide" data-ng-show="node.selected" data-ng-click="' + treeId + '.deleteNodeLabel(node)"><i class="fa fa-close"></i></span><div data-ng-hide="node.collapsed" data-tree-id="' + treeId + '" data-tree-model="node.' + nodeChildren + '" data-node-id=' + nodeId + ' data-node-label=' + nodeLabel + ' data-node-children=' + nodeChildren + '></div></li></ul>'
                if treeId and treeModel
                    if attrs.angularTreeview
                        scope[treeId] = scope[treeId] or {}
                        scope[treeId].selectNodeHead = scope[treeId].selectNodeHead or (selectedNode) ->
                                selectedNode.collapsed = !selectedNode.collapsed
                                return
                        scope[treeId].selectNodeLabel = scope[treeId].selectNodeLabel or (selectedNode) ->
                                if scope[treeId].currentNode and scope[treeId].currentNode.selected
                                    scope[treeId].currentNode.selected = undefined
                                selectedNode.selected = 'selected'
                                scope[treeId].currentNode = selectedNode
                                return
                    element.html('').append $compile(template)(scope)
                return
    ])
    #添加ngScroll滚动条指令集
    .directive('ngScroll',['$parse', ($parse)->
        (scope, element, attr)->
            fn = $parse(attr.ngScroll)
            element.bind('scroll', (event)->
                scope.$apply(->
                    fn(scope, {
                        $event: event
                    })
                )
            )
    ])
    # switch stylesheet file
    .directive('uiColorSwitch', [ ->
        return {
            restrict: 'A'
            link: (scope, ele, attrs) ->
                ele.find('.color-option').on('click', (event)->
                    $this = $(this)
                    hrefUrl = undefined

                    style = $this.data('style')
                    if style is 'loulou'
                        hrefUrl = 'styles/main.css'
                        $('link[href^="styles/main"]').attr('href',hrefUrl)
                    else if style
                        style = '-' + style
                        hrefUrl = 'styles/main' + style + '.css'
                        $('link[href^="styles/main"]').attr('href',hrefUrl)
                    else
                        return false

                    event.preventDefault()
                )
        }
    ])
    # history back button
    .directive('goBack', [ ->
        return {
            restrict: "A"
            controller: [
                '$scope', '$element', '$window'
                ($scope, $element, $window) ->
                    $element.on('click', ->
                        $window.history.back()
                    )
            ]
        }
    ])
    # 时钟控件
    .directive('clockfusion', ['$interval', 'dateFilter'
        ($interval, dateFilter)->
            (scope, element, attrs)->
                format = 'y-M-d H:mm:ss'
                if attrs.clockfusion
                    format = attrs.clockfusion

                updateTime = ()->
                    element.text(dateFilter(new Date(),format))
                updateTime()
                stopTime = $interval(updateTime, 1000)
                element.on('$destroy',()->
                    $interval.cancel(stopTime)
                )
    ])
    #全屏功能
    # history back button
    .directive('fullscreen', [ ->
            return {
                restrict: "A"
                controller: [
                    '$scope', '$element','$document'
                    ($scope, $element,$document) ->
                        $element.html('<span class="fa fa-expand"></span>')
                        $element.on('click', ->
                            body =$document.find('#app')
                            if body.hasClass('body-wide')
                                $element
                                .find('.fa')
                                .removeClass('fa-compress')
                                body.removeClass('body-wide')
                            else
                                $element
                                .find('.fa')
                                .addClass('fa-compress')
                                body.addClass('body-wide')
                        )
                ]
            }
    ])
    .directive('i18n', [
          'localize'
          (localize) ->
              i18nDirective =
                  restrict: "EA"
                  updateText: (ele, input, placeholder) ->
                      result = undefined

                      if input is 'i18n-placeholder'
                          result = localize.getLocalizedString(placeholder)
                          ele.attr('placeholder', result)
                      else if input.length >= 1
                          result = localize.getLocalizedString(input)
                          ele.text(result)

                  link: (scope, ele, attrs) ->
                      scope.$on('localizeResourcesUpdated', ->
                          i18nDirective.updateText(ele, attrs.i18n, attrs.placeholder)
                      )

                      attrs.$observe('i18n', (value) ->
                          i18nDirective.updateText(ele, value, attrs.placeholder)
                      )

              return i18nDirective
      ])
    .directive('toggleNavCollapsedMin', [
          '$rootScope'
          ($rootScope) ->
              return {
              restrict: 'A'
              link: (scope, ele, attrs) ->
                  app = $('#app')

                  ele.on('click', (e) ->
                      if app.hasClass('nav-collapsed-min')
                          app.removeClass('nav-collapsed-min')
                      else
                          app.addClass('nav-collapsed-min')
                          $rootScope.$broadcast('nav:reset')

                      e.preventDefault()
                  )
              }
    ])
# for accordion/collapse style NAV
    .directive('collapseNav', [ ->
          return {
          restrict: 'A'
          link: (scope, ele, attrs) ->
              $window = $(window)
              $lists = ele.find('ul').parent('li') # only target li that has sub ul
              $lists.append('<i class="fa fa-angle-down icon-has-ul-h"></i><i class="fa fa-angle-right icon-has-ul"></i>')
              $a = $lists.children('a')
              $listsRest = ele.children('li').not($lists)
              $aRest = $listsRest.children('a')

              $app = $('#app')
              $nav = $('#nav-container')
              $a.on('click', (event) ->
# disable click event when Nav is mini style || DESKTOP horizontal nav
                  if ( $app.hasClass('nav-collapsed-min') || ($nav.hasClass('nav-horizontal') && $window.width() >= 768) ) then return false

                  $this = $(this)
                  $parent = $this.parent('li')
                  $lists.not( $parent ).removeClass('open').find('ul').slideUp()
                  $parent.toggleClass('open').find('ul').slideToggle()

                  event.preventDefault()
              )
              setTimeout(->
                  $(document).find('#nav a').each((e,d)->#菜单默认focus状态
                        if $(d).attr('href') isnt location.hash
                            return
                        if $(d).parents().eq(1).attr('id') is 'nav'
                            dom = $(d)
                        if $(d).find('i.fa.fa-angle-right')
                            dom = $(d)
                            .parent()
                            .addClass('active')
                            .parent()
                            if !!$(document).find('.nav-vertical').size() then dom.parent().parent().show()
                        dom
                        .parent()
                        .addClass('open active')

                  )
              ,0)
              $aRest.on('click', (event) ->
                  $lists.removeClass('open').find('ul').slideUp()
              )

              # reset NAV, sub Ul should slideUp
              scope.$on('nav:reset', (event) ->
                  $lists.removeClass('open').find('ul').slideUp()
              )

              # removeClass('nav-collapsed-min') when size < $screen-sm
              # reset Nav when go from mobile to horizontal Nav
              Timer = undefined
              prevWidth = $window.width()
              updateClass = ->
                  currentWidth = $window.width()
                  # console.log('prevWidth: ' + prevWidth)
                  # console.log('currentWidth: ' + currentWidth)
                  if currentWidth < 768 then $app.removeClass('nav-collapsed-min')
                  if prevWidth < 768 && currentWidth >= 768 && $nav.hasClass('nav-horizontal')
# reset NAV, sub Ul should slideUp
                      $lists.removeClass('open').find('ul').slideUp()

                  prevWidth = currentWidth


              $window.resize( () ->
                  clearTimeout(t)
                  t = setTimeout(updateClass, 300)
              )

          }
      ])
# toggle on-canvas for small screen, with CSS
    .directive('toggleOffCanvas', [ ->
          return {
          restrict: 'A'
          link: (scope, ele, attrs) ->
              ele.on('click', ->
                  $('#app').toggleClass('on-canvas')
              )
          }
    ])
    .directive('uiTime', [ ->
      return {
        restrict: 'A'
        link: (scope, ele) ->
          startTime = ->
            today = new Date()
            h = today.getHours()
            m = today.getMinutes()
            s = today.getSeconds()

            m = checkTime(m)
            s = checkTime(s)

            time = h+":"+m+":"+s
            ele.html(time)
            t = setTimeout(startTime,500)
          checkTime = (i) -> # add a zero in front of numbers<10
            if (i<10) then i = "0" + i
            return i

          startTime()
      }
    ])
    .directive('uiNotCloseOnClick', [ ->
        return {
        restrict: 'A'
        compile: (ele, attrs) ->
          ele.on('click', (event) ->
            event.stopPropagation()
          )
        }
      ])

    .directive('slimScroll', [ ->
        return {
        restrict: 'A'
        link: (scope, ele, attrs) ->
          ele.slimScroll({
            height: attrs.scrollHeight || '100%'
          })
        }
    ])
)
