define(['app', 'logger', 'date', 'factory/datatable','jquery-ui'], (app)->
    app.directive('datatable',
        ()->
            {
            restrict: 'EAC'
            transclude: true,
            scope: {
                datatable: '='
            }
            templateUrl: (elem, attr)->
                templateName = attr.type
                templateName = 'table' if !templateName
                templateUrl = 'views/directives/base-' + attr.type + '.html'
                if templateName.split('#').length > 1
                    templateUrl = "views/" + window.project + "/table/" + templateName.split('#')[1] + ".html"
                return templateUrl
            link: (scope, element, attrs)->
            controller: ($scope, $element, DatatableBase, $filter, logger, $timeout)->

                $scope.edittype = $element.attr('edittype')
                #单行编辑
                getAllowType = (t)->
                    !_.contains([
                        'string'
                        'int'
                        'float'
                    ], t)
                setFocusDom = (DOM)->
                    DOM.focus()
                    tdDom = $element.find('.td-focus')
                    fix_width = $(document).find('#nav').width()
                    fix_height = $(document).find('#header').height() + 15
                    if !tdDom.offset() then return false
                    DOM
                    .css(
                        "top": (tdDom.offset().top - fix_height) + 'px'
                        "left": (tdDom.offset().left - fix_width) + 'px'
                        "width": (+tdDom.width() + 8) + 'px'
                    )
                $scope.getTD = (i, n, k)->
                    if i isnt 0 and !i
                        return false
                    if i is -1 or ($scope.tdFocus.key is 0 and k is -1) or $scope.filterdata().length is i
                        return false
                    field = $filter('filter')(
                        $scope.filterdata()[i]['$field']
                        {show: true}
                    )
                    if k is 1 and $scope.tdFocus.key + 1 is field.length
                        return false
                    field.forEach((item, eq)->
                        if n is false and item.name is $scope.tdFocus.name
                            $scope.tdFocus.key = eq + k
                            n = field[eq + k]
                        else
                            $scope.tdFocus.key = eq if item.name is n
                    )
                    if typeof n is "object" and getAllowType(n.type)
                        return false
                    n = n.name if typeof n is "object"
                    $scope.filterdata().forEach((item)->
                        item['$focus'] = null
                    )
                    $scope.filterdata()[i]['$focus'] = n
                    $scope.tdFocus.index = i
                    $scope.tdFocus.name = n
                $scope.tdFocus = {}
                $scope.tdEdit = {}
                $scope.getTDclick = (i, n, e, t)->
                    if getAllowType(t)
                        return false
                    $scope.getTD(i, n)
                    $scope.tdEdit.show = true
                    setTimeout(->
                        DOM = $(document).find('.td-line-focus')
                        setFocusDom(DOM)
                    , 0)
                    e.preventDefault()
                    e.stopPropagation()
                $scope.filterdata = ->
                    $filter('filter')(
                        $scope.currentPageStores
                        $scope.datatableFilter
                    )
                $scope.keyboardAction =
                    "13": (t)->#回车键`编辑
                        if t and getAllowType(t)
                            return false
                        $scope.tdEdit.shown = true
                        $scope.tdEdit.val = $scope.filterdata()[$scope.tdFocus.index]
                        DOM = $element.find('.td-line-edit')
                        $timeout(->
                            setFocusDom(DOM)
                        , 0)
                    "27": ->#ESC键`取消
                        $scope.getTDBlur()
                    "37": ->#左键
                        $scope.getTD($scope.tdFocus.index, false, -1)
                    "38": ->#上键
                        $scope.getTD($scope.tdFocus.index - 1, $scope.tdFocus.name, null)
                    "39": ->#右键
                        $scope.getTD($scope.tdFocus.index, false, 1)
                    "40": ->#下键
                        $scope.getTD($scope.tdFocus.index + 1, $scope.tdFocus.name, null)
                $scope.getTDkeydown = (e)->
                    key = e.keyCode.toString()
                    $scope.keyboardAction[key]() if $scope.keyboardAction[key]
                $scope.getTDBlur = ()->
                    if $scope.tdEdit.shown and $scope.tdEdit.focus is undefined
                        return false
                    if $scope.tdEdit.show or ( $scope.tdEdit.shown and $scope.tdEdit.focus)
                        $scope.filterdata()[$scope.tdFocus.index]['$focus'] = null
                        $scope.tdFocus = {}
                        $scope.tdEdit.show = false
                        $scope.tdEdit.shown = undefined
                        $scope.tdEdit.focus = undefined
                $scope.getKeydown = (e)->
                    key = e.keyCode.toString()
                    if key is '13' and $scope.filterdata().length is $scope.tdFocus.index
                        return $scope.getTDBlur()
                    if key is '13'
                        $scope.tdEdit.save = 0
                        if $scope.filterdata()[$scope.tdFocus.index]
                            $scope.filterdata()[$scope.tdFocus.index].$on('after-save', ->
                                $scope.tdEdit.save++
                                if $scope.tdEdit.save == 1
                                    logger.logSuccess('提交成功')
                                    if $scope.filterdata().length is $scope.tdFocus.index + 1
                                        return $scope.getTDBlur()
                                    $scope.keyboardAction['40']()
                                    $scope.getTDkeydown(e)
                            ).$on('after-save-error', ->
                                logger.logError('提交失败')
                                #$scope.filterdata()[$scope.tdFocus.index].$restore()
                            ).$save([
                                $scope.tdFocus.name
                            ])
                    if key is '27'
                        $scope.getTDBlur()


                #显示回收站图标
                $scope.showtrash = (e)->
                    $scope.showTrash = e

                #表头字段拖动
                $scope.onDropComplete = (i, o)->
                    otherIndex = $scope.currentPageStores.$field.indexOf(o)
                    if i is -1
                        $scope.currentPageStores.$field[otherIndex].show = false
                        return $scope.showTrash = false
                    otherObj = $scope.currentPageStores.$field[i]
                    $scope.currentPageStores.$field[i] = o
                    $scope.currentPageStores.$field[otherIndex] = otherObj

                $scope.tableConfigure =
                    allowAdd:
                        val: false
                        shown: false
                        name: "新增"
                    tdFocus:
                        val: false
                        shown: false
                        name: "焦点"
                    tdEdit:
                        val: false
                        shown: false
                        name: "单行编辑"
                    columnDrop:
                        val: false
                        shown: false
                        name: "单列拖拽"
                    localSearch:
                        val: false
                        shown: false
                        name: "筛选"
                    serverSearch:
                        val: false
                        shown: false
                        name: "搜索"
                    checkbox:
                        val: false
                        shown: false
                        name: "复选框"
                    statistics:
                        val: false
                        shown: false
                        name: "单列统计"

                $scope.datatableFilter = {}
                #字段拷贝

                $scope.query = {}

                $scope.sortLocal =
                    order: ''
                    row: ''
                    class: ''
                    tdclass: 'sort-td'
                $scope.row = ''
                #默认页码
                $scope.currentPage = 1
                $scope.currentPageStores = []
                #每页显示量， 可配置
                if typeof $scope.datatable.sizelist is 'undefined'
                    $scope.numPerPageOpt = [10, 20, 50, 100]
                else
                    $scope.numPerPageOpt = $scope.datatable.sizelist
                #默认显示量取第二个
                $scope.numPerPage = $scope.numPerPageOpt[1]
                #加载资源路径
                $scope.Source = $scope.datatable.model.$collection().$initModel(->
                    $scope.Source.$initModel = 'ok'
                    if $scope.Source.$status == 'ok'
                        $scope.currentPageStores.$searchBelongsTo()
                )
                $scope.$search_field = $filter('filter')($scope.Source.$build().$field,{server:true})
                $scope.$search_field = angular.copy($scope.Source.$build().$field) if $scope.$search_field.length == 0
                $scope.$search_field.push(
                    {
                        name: 'date'
                        text: '时间'
                        type: 'daterange'
                    }
                )
                $scope.Source.$loaded = false
                #          #获取fields的select类型数据
                #          if typeof $scope.fields isnt  'undefined'
                #            DatatableBase.catSelect($scope.fields)
                #获取查询条件的select类型并关联
#                if typeof $scope.datatable.search isnt 'undefined'
#                    DatatableBase.catSelect($scope.datatable.search)
                #搜索，主要加载入口
                $scope.goTo = (page)->
                    $scope.select(page,null,!0)
                $scope.select = (page,str,stat) ->
                    if stat != !0
                        $scope.currentPage = 1
                        setTimeout ->
                            if $element.find('.reset-page').size() > 0 then $element.find('.reset-page:last-child').click()
                        ,0
                    $scope.currentPageStores = $scope.Source
                    $scope.query['_'] = +new Date()
                    $element.attr('loading_id', $scope.query['_'])
                    $scope.query.page = page
                    $scope.query.page_size = $scope.numPerPage
                    $scope.query.order = $scope.row
                    for key,value of $scope.query
                        if angular.isDate(value) is true
                            $scope.query[key] = +new Date(value)
                    fetchTimes = 0
                    $scope.before() if $scope.before
                    $scope.Source.$refresh($scope.query).$on 'after-fetch-many',->
                        fetchTimes++
                        if fetchTimes > 1 then return false
                        $scope.after() if $scope.after
                        if $scope.Source.$initModel == 'ok'
                            $scope.currentPageStores.$searchBelongsTo()


#                #表格对select关联显示
#                $scope.select2value = DatatableBase.select2value
#                #select关联变动
#                $scope.relation = (value, name)->
#                    params = {}
#                    params[name] = value
#                    DatatableBase.catSelect($scope.datatable.search, params, {name: name, scope: $scope.query})
                #更改查询条件时执行的动作
                $scope.onFilterChange = ->
                    $scope.currentPage = 1
#                    $scope.row = ''
                    $scope.select($scope.currentPage)
                #更改每页显示量后的动作
                $scope.onNumPerPageChange = (sum)->
                    $scope.numPerPage = sum
                    $scope.select($scope.query.page)
                #更改排序后续动作
                $scope.onOrderChange = ->
                    $scope.currentPage = 1
                    $scope.select($scope.currentPage)
                #查询条件
                $scope.search = ->
                    $scope.currentPageStores = []
                    $scope.onFilterChange()
                #更改排序
                $scope.mouseEnter = (type)->
                    if angular.isUndefined($scope.tableConfigure.tdFocus)
                        return
                    if $scope.tableConfigure.tdFocus.val and type isnt 'edit'
                        $scope.tdIndex = @$index
                $scope.mouseLeave = ()->
                    $scope.tdIndex = null
                $scope.$allChange = ()->
                    for i in $scope.currentPageStores
                        i.$checked = @$allChecked
                #客户端排序
                $scope.orderLocal = (rowName)->
                    if $scope.sortLocal.order is '-'
                        $scope.sortLocal.order = ''
                        $scope.sortLocal.class = 'sort-down'
                    else
                        $scope.sortLocal.order = '-'
                        $scope.sortLocal.class = 'sort-up'
                    $scope.sortLocal.row = rowName
                    $scope.currentPageStores = DatatableBase.orderBy(
                        $scope.currentPageStores
                        $scope.sortLocal.order + $scope.sortLocal.row
                    )
                $scope.order = (rowName)->
                    if $scope.row == rowName
                        return
                    $scope.row = rowName
                    $scope.onOrderChange()
                $scope.initSearch = angular.copy($scope.search)
                #自定义
                if $scope.datatable and $scope.datatable.init
                    $scope.datatable.init($scope, $element, DatatableBase, $filter, logger, $timeout)
                # 默认启动
                init = (->
                    $timeout(->
                        if $scope.initSearch then $scope.initSearch(1)
                    , 0))()
            }
    )
    .directive('edittable',
        ()->
            {
            restrict: 'EAC'
            require: ['^ngModel']
            scope: {
                ngModel: '='
                rootscope: '='
            }
            link: (scope, element, attrs, ngModel, controller)->
            controller: ['$scope', '$element', '$uibModal', 'logger'
                ($scope, $element, $uibModal, logger)->
                    $element.on('click', ()->
                        templateName = $element.attr('edittable')
                        templateName = 'table' if !templateName
                        templateUrl = "views/directives/edit-" + templateName + ".html"
                        if templateName.split('#').length > 1
                            templateUrl = "views/" + window.project + "/edit/" + templateName.split('#')[1] + ".html"
                        editController = $scope.rootscope
                        modalInstance = $uibModal.open(
                            templateUrl: templateUrl
                            controller: (editController, $scope, $uibModalInstance, item, $timeout)->
                                $scope.init = ->
                                    if item.store.$pk is undefined
                                        item.store = item.store.$build()
                                        $scope.beforeBuild and $scope.beforeBuild()
                                        for val in item.store.$field
                                            item.store[val.name] = if val['default']? then val['default'] else null;
                                            if val.type is 'select' and val.select? and val['default']?
                                                id = {}
                                                id[val.select.key] = val['default']
                                                item.store[val.name] = _.where(item.store.$scope['$_'+val.name],id)[0]
                                            if val.readOnly == !0 then delete item.store[val.name]
                                        $scope.afterBuild and $scope.afterBuild()
                                    $scope.store = item.store
                                    $scope.afterInit and $scope.afterInit()
                                $scope.scrollData = # 动态select载入
                                    get: (e, key, kw)->
                                        param = key + 'param'
                                        if kw
                                            @[param].search = kw
                                            @[param].page = 1
                                            $scope.store.$scope['$_' + key].$refresh(@[param])
                                        if this[key] or !e then return false
                                        if e and $(e.target).children('li').height() - $(e.target).height() is e.target.scrollTop
                                            this[key] = true
                                            _this = @
                                            pageSize = _.where($scope.store.$field, {name: key})[0].select.limit
                                            @[param] =
                                                page_size: pageSize
                                                page: parseInt(if !pageSize then 0 else $scope.store.$scope['$_' + key].length / pageSize) + 1
                                            @[param].search = kw if kw
                                            $scope.store.$scope['$_' + key].$on('after-fetch-many', ->
                                                _this[key] = false
                                            ).$fetch(@[param])
                                $scope.cancel = ->
                                    $scope.revert()
                                    $uibModalInstance.dismiss "cancel"
                                    return
                                $scope.revert = ->
                                    field = angular.copy $scope.store.$field
                                    $scope.store.$restore()
                                    $scope.store.$field = field #保持表头状态
                                $scope.submitForm = ()->
                                    $scope.Loading = !0
                                    $scope.store.$$cb = {} #清除on监听
                                    $scope.store.$save().$moveTo(0)
                                    .$on 'after-save', ->
                                        $uibModalInstance.close()
                                    .$on 'after-save-error',->
                                        $scope.Loading = !1
                                $scope.draggable = ->
                                    $('.modal-dialog').draggable({handle: '.panel-heading'}) #modal可拖拽


                                #自定义
                                if editController and editController.edit
                                    editController.edit($scope, $uibModalInstance, item)
                                $timeout ->
                                    try
                                        _.map $(document).find('.modal-dialog [required="required"].ng-pristine'),(e)->
                                            if $(e).val()? and $(e).val() != '' then $(e).removeClass('ng-pristine')
                                    if $scope.draggable then $scope.draggable()
                                , 0
                                do->
                                    $scope.init()
                            size: 'lg'
#                            keyboard: !1
#                            backdrop: 'static'
                            resolve:
                                item: ()->
                                    store: $scope.ngModel
                                editController: editController
                        )
                        modalInstance.result.then ->
                            try
                                if $scope.ngModel.$closed then return $scope.ngModel.$closed()#新增后
                                if $scope.ngModel.$scope.$closed then return $scope.ngModel.$scope.$closed()#编辑保存后
                                return
                        ,->
                            try
                                if $scope.ngModel.$dismissed then $scope.ngModel.$dismissed()
                                if $scope.ngModel.$scope.$dismissed then $scope.ngModel.$scope.$dismissed()#取消
                                return
                    )
            ]
            }
    ).directive('deltable',
        ()->
            {
            restrict: 'EAC'
            require: ['^ngModel']
            scope: {
                ngModel: '='
            }
            link: (scope, element, attrs, ngModel, controller)->
            controller: ['$scope', '$element', '$uibModal', 'logger'
                ($scope, $element, $uibModal, logger)->
                    $element.on('click', ()->
                        modalInstance = $uibModal.open(
                            templateUrl: "views/directives/base-" + $element.attr('deltable') + ".html"
                            controller: $element.attr('deltable') + 'Ctrl'
                            resolve: {
                                item: ()->
                                    {
                                    store: $scope.ngModel
                                    }
                            }
                        )
                        modalInstance.result.then ((res) ->
                            $scope.ngModel.$scope.$totalCount--
                            $scope.ngModel.$scope.$delSuccess(res) if $scope.ngModel.$scope.$delSuccess
                            logger.logSuccess('删除成功')
                            return
                        )
                    )
            ]
            }
    ).controller('confirmCtrl', [
        '$scope', '$uibModalInstance', 'item','logger'
        ($scope, $uibModalInstance, item, logger)->
            $scope.cancel = ->
                $uibModalInstance.dismiss "cancel"
                return
            $scope.submitForm = ->
                item.store.$destroy()
                .$on 'after-destroy',(e)->
                    $uibModalInstance.close(e)
                .$on 'after-destroy-error',->
                    logger.logError('删除失败')
                    $uibModalInstance.dismiss "cancel"
                return
    ])
)

