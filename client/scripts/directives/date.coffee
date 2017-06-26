define(['angularAMD'],(angularAMD)->
    angularAMD.directive('rangedate', [ ->
        {
            restrict: 'AE'
            transclude: true
            require: '^ngModel'
            scope: {
                ngModel: '='
                defaultVal: '='
            }

            templateUrl:(elem, attr)->
              'views/directives/base-date.html'
            link:(scope, element, attrs)->
            controller:($scope,$filter,$element,dataPak)->
                $scope.status = {}
                $scope.isopen = {}
                $scope.time = {}
                $scope.status.startTime = if $element.attr('startTime') then $element.attr('startTime') else 'startTime'
                $scope.status.endTime = if $element.attr('endTime') then $element.attr('endTime') else 'endTime'
                $scope.status.format = if $element.attr('format') then $element.attr('format') else 'yyyy-MM-dd'
                $scope.isTimeType = if /(hh|HH)/.test($scope.status.format) then !0 else !1
                $scope.openStartTime = ($event)->
                    $event.preventDefault()
                    $event.stopPropagation()
                    $scope.status.openedStart = !0
                $scope.openEndTime = ($event)->
                    $event.preventDefault()
                    $event.stopPropagation()
                    $scope.status.openedEnd = !0
                $scope.getdateFilter = (dateFilter)->
                    if dateFilter.method == 'userDefined' then return false
                    limi = dataPak[dateFilter.method](dateFilter.num,dateFilter.lo)
                    $scope.ngModel[$scope.status.startTime] = limi.start
                    $scope.ngModel[$scope.status.endTime] = limi.end-1

                $scope.list = [
                    {text:'今日',method:'Day',num:0,lo:1}
                    {text:'昨天',method:'Day',num:1,lo:1}
                    {text:'前天',method:'Day',num:2,lo:1}
                    {text:'本周',method:'Week',num:0,lo:1}
                    {text:'上周',method:'Week',num:1,lo:1}
                    {text:'本月',method:'Month',num:0,lo:1}
                    {text:'上月',method:'Month',num:1,lo:1}
                    {text:'过去三天',method:'Day',num:1,lo:3}
                    {text:'过去七天',method:'Day',num:1,lo:7}
                    {text:'最近一个月',method:'Day',num:0,lo:30}
                    {text:'最近三个月',method:'Day',num:0,lo:90}
                    {text:'最近半年',method:'Day',num:0,lo:182}
                    {text:'最近一年',method:'Day',num:0,lo:365}
                    {text:'自定义',method:'userDefined'}
                ]
                defaultVal = $element.attr('default') || $scope.defaultVal
                $scope.dateFilter =  if defaultVal then $scope.list[defaultVal] else $scope.list[0]
                $scope.getdateFilter($scope.dateFilter)

                $scope.hstep = 1
                $scope.mstep = 15
                $scope.ismeridian = !0
                $scope.toggleMode = ->
                    $scope.ismeridian = !$scope.ismeridian
                $scope.selectTime = (arg)->
                    d = new Date
                    c = angular.copy($scope.ngModel[arg])
                    c = d if !_.isDate c
                    c.setHours(d.getHours())
                    c.setMinutes(d.getMinutes())
                    $scope.ngModel[arg] = c

                $scope.closeTime = (arg)->
                    $scope.isopen[arg] = false

                $scope.change = (arg)->
                    $scope.dateFilter = _.where($scope.list,method:'userDefined')[0]
                    setTimeout(->
                        $scope.isopen[arg] = true
                    ,0)

        }
    ])
    .directive('gstime', [ ->
        {
            restrict: 'AE'
            transclude: true
            require: '^ngModel'
            scope: {
                ngModel: '='
                key: '='
            }
            templateUrl:(elem, attr)->
                'views/directives/base-gstime.html'
            link:(scope, element, attrs)->
            controller:($scope,$filter,$element)->
                $scope.config =
                    isopen:!1
                    format:"yyyy-MM-dd"#yyyy-MM-dd HH:mm:ss
                    isTimeType:!1
                $scope.config.isTimeType = !0 if $element.attr('gstime') is 'time'
                $scope.config.format = $element.attr('format') if !!$element.attr('format')
                if $scope.key?
                    $scope.$watchCollection('key',(o,n)->
                        $scope.min = if o.min? and o.min isnt n.min then o.min else undefined
                        $scope.max = if o.max? and o.max isnt n.max then o.max else undefined
                    )
                    $scope.config.format = $scope.key.format if $scope.key.format?
                $scope.isTimeType = if /(hh|HH)/.test($scope.config.format) then !0 else !1
                $scope.config.open = ($event)->
                    $event.preventDefault()
                    $event.stopPropagation()
                    $scope.config.isopen = !0

                $scope.hstep = 1
                $scope.mstep = 15
                $scope.ismeridian = !0
                $scope.toggleMode = ->
                    $scope.ismeridian = !$scope.ismeridian
                $scope.selectTime = ()->
                    d = new Date
                    c = angular.copy($scope.ngModel)
                    c = d if !_.isDate c
                    c.setHours(d.getHours())
                    c.setMinutes(d.getMinutes())
                    $scope.ngModel = c

                $scope.closeTime = ()->
                    $scope.timeIsOpen = false

                $scope.change = ()->
                    setTimeout(->
                        $scope.timeIsOpen = true
                    ,0)

        }
    ])
    .factory('dataPak',[->
        {
            getTimes :  ()->
                now = new Date()
                now.setHours(0)
                now.setMinutes(0)
                now.setSeconds(0)
                now.setMilliseconds(0)
                start = angular.copy(now)
                end = angular.copy(now)
                {start:start,end:end,now:now}
            Day : (num,lo)->
                pak = @getTimes()
                pak.start.setDate(pak.now.getDate()-num-lo+1)
                pak.end.setDate(pak.now.getDate()-num+1)
                pak.end = new Date(+pak.end-1) if num is 0
                pak
            #num:0为本周，<0 则为未来几周,lo 为 单周双周
            Week : (num,lo)->
                pak = @getTimes()
                if typeof lo is 'undefined'
                  lo=1
                weekNow = pak.now.getDay()
                if weekNow is 0
                  weekNow = 7
                pak.start.setDate(pak.now.getDate()-(7*(lo-1))-(7*num)-1*(weekNow-1))
                pak.end.setDate(pak.now.getDate()-(7*num)+7-weekNow)
                pak
            #num:0为本月，<0 则为未来几月,lo 为 单月双月
            Month:(num,lo)->
                pak = @getTimes()
                monthNow = pak.now.getMonth()
                pak.start.setDate(1)
                pak.end.setDate(1)
                pak.start.setMonth(monthNow-num-lo+1)
                pak.end.setMonth(monthNow-num+1)
                pak
        }
    ])
)
