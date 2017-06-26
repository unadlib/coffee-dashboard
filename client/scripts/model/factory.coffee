define(['angularAMD'],(angularAMD)->
    angularAMD.factory('factoryTable',(inflector,$injector,logger,statistics)->
        $config:
            style:'DjangoDRFPagedApi'
            primaryKey:'_id'
            jsonRootMany:'results'
            jsonRoot:'.'
            jsonRootSingle:'results'
            jsonLinks:'.'
            singleRoot:'results'
            jsonMeta:'.'
        $extend:
            Collection:
                $initModel:(callback)->
                    _this = @
                    $field = _this.$build().$field
                    $field = _.where($field, 'select')
                    i = 0
                    size = $field.length
                    $field.forEach((item)->
                        model = $injector.get(item.select.model)
                        source = model.$collection()
                        if item.type is 'multiple_refresh'
                            _this['$_'+item['name']] = source.$fetch({page:1,page_size:item.select.limit})
                        else
                            _this['$_'+item['name']] = source.$resolve().$on 'after-fetch-many',->
                                i++
                                if i is size
                                    callback()
                    )
                    _this
            Model:
                decodeName: inflector.camelize
                encodeName: (_v)->inflector.parameterize(_v, '_')
                encodeUrlName:inflector.parameterize
            List:
                $searchBelongsTo:()->
                    _this = this
                    $field = _.where(_this.$build().$field, 'select')
                    _this.forEach((item)->
                        $field.forEach((field)->
                            if field.type is "select" and item[field.name]
                                item[field.name] = _.where(_this['$_'+field.name], {$pk:item[field.name]['$pk']})[0]
                            if field.type is "multiple" and item[field.name] and _.type.is().Array(item[field.name])
                                item[field.name] = item[field.name].map((li)->
                                    _.where(_this['$_'+field.name], {$pk:li})[0]
                                )
                            item.$cmStatus=angular.copy(item)
                            delete item.$cmStatus.$cmStatus
                            delete item.$cmStatus.$scope
                        )
                    )
                    _this
        $hooks:
            'after-fetch-many':(_req)->
                @$totalCount = _req.data.count
                _this = @
                if !@ or !@[0] or !@[0].$field
                    return false
                @[0].$field.forEach((result,key)->
                    statistics.call @,result,_this
                )
            'before-save':(_req)->
                $field = _.where(@$field, {type: "multiple"})
                $field.forEach((item)->
                    isEncodeName = !!$injector.get('AMSApi').$$chain[1].$extend.Model.encodeName
                    item.name = _._(item.name) if _._(item.name) isnt item.name and isEncodeName
                    if !!_req.data[item.name] and !item.select.belongsto and _.type.is().Array(_req.data[item.name])
                        _req.data[item.name]=_req.data[item.name].map((tag)->
                            tag[item.select.key]
                        )
                )
            'after-save-error':(res)->
                if res.config.headers['ng-NoLogger'] and res.data.error != -2 then return false
                if angularAMD.logError then return angularAMD.logError(logger,res.data)#自定义报错
                if res and res.data and res.data.message
                    logger.logError(res.data.message)
                else
                    if res.data and _.isArray(res.data) and res.data.length > 0 then return  logger.logError(res.data[0])
                    logger.logError('提交失败')
            'after-save':(res)->
                _this = @
                $field = _.where(_this.$field, 'select')
                $field.forEach((field)->
                    isEncodeName = !!$injector.get('AMSApi').$$chain[1].$extend.Model.encodeName
                    field.name = _.tF(field.name) if _.tF(field.name) isnt field.name and isEncodeName
                    if field.type is "multiple" and !field.select.belongsto and _.type.is().Array(_this[field.name])
                        _this[field.name] = _this[field.name].map((li)->
                            _.where(_this.$scope['$_'+field.name], {$pk:li})[0]
                        )
                    _this.$cmStatus=angular.copy(_this)
                    delete _this.$cmStatus.$cmStatus
                    delete _this.$cmStatus.$scope
                )
                @$field.forEach((result,key)->
                    statistics.call @,result,_this.$scope
                )
                logger.logSuccess('提交成功')
    )
    .factory('statistics',->
        (result,_this)->
            if result.type is 'boolean' or result.type is 'checkbox'
                _.forEach(_this,(d)->
                    d[result.name]= eval(d[result.name])
                )
            if result.extra is 'total' or result.extra is 'average'#表格统计
                all = _.pluck(_this,result.name)
                result.$extra = _.reduce(all,(i,s)->
                    _.getFloat(i)+_.getFloat(s)
                )
            if result.extra is 'average'
                result.$extra = if all.length is 0 then 0 else (result.$extra/all.length).toFixed(2)

    )
)
