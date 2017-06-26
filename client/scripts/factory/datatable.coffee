define(['app'], (app)->
    app.factory('DatatableBase', ['$http',
        ($http)->
            {
                catSelect: (docs, params, relation)->
                    paramsString = ''
                    if typeof params isnt 'undefined'
                        for key,value of params
                            if value is ''
                                continue
                            paramsString = paramsString + '&' + key + '=' + value
                    docs.forEach((item)->
                        if item.type is 'select'
                            if (typeof relation is 'undefined') or (typeof relation isnt 'undefined' and relation.name is item.relation)
                                if typeof relation isnt 'undefined' and relation.name is item.relation
                                    relation.scope[item.name] = ''
                                return $http.get(item.select.url + '?type=select' + paramsString).success(
                                    (data)->
                                        key = item.select.key
                                        value = item.select.value
                                        item.docs = []
                                        for im in data.data
                                            item.docs.push({key: im[key], value: im[value]})
                                )
                    )
                select2value: (list, key)->
                    if typeof list is 'undefined'
                        return ''
                    for item in list
                        if item.key is key
                            return item.value
                addAction: (docs)->
                    docs.push({
                        name: '$edit'
                        text: '操作'
                        type: 'edit'
                        show: true
                        link: false
                        sort: false
                    })
                addDate: (docs)->
                    docs.concat([{
                        name: 'date'
                        text: '时间'
                        type: 'daterange'
                    }])
                orderBy: (data, field)->
                    isObject = (arg)->
                        Object.prototype.toString.call(arg) is "[object Object]"
                    if field.charAt(0) is '-'
                        field = field.replace(/^-/, '')
                        contrast = !0
                    for i,j in data
                        for x,k in data
                            select = _.where(data.$field, {name: field})[0].select
                            e = if isObject(i[field]) then i[field][select.value] else i[field]
                            c = if isObject(x[field]) then x[field][select.value] else x[field]
                            byList = if !!contrast then e > c else e < c
                            if byList
                                data[j] = [data[k], data[k] = data[j]][0]
                    data
            }
    ])
)
