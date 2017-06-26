define(['angularAMD'
    'angular'
    'angular-route'
    'angular-animate'
    'angular-restmod'
    'angular-restmod-style'
    'ngStorage'
    'bootstrap'
    'slimscroll'
    'ngTagsInput'
], (angularAMD)->
    'use strict'
    if angularAMD.main.title
        $(document).find('title').text(angularAMD.main.title)
    if _
        _.getFloat = (i)->
            if !i or !parseFloat(i) then 0 else parseFloat(i)
        _.type = #判断类型 demo:_.type.is().Object({})
            get: (arg)->
                Object.prototype.toString.call(arg)
            fn: (fn, _this)->
                _this[fn] = (arg)->
                    _this.get(arg) is "[object " + fn + "]"
            is: ->
                _this = @
                [
                    'String'
                    'Number'
                    'Boolean'
                    'Array'
                    'Date'
                    'Function'
                    'RegExp'
                    'Object'
                ].forEach((i)->
                    _this.fn(i, _this)
                )
                _this
        _.cInitial = (s)->
            s.charAt(0).toUpperCase() + s.slice(1)
        _.tF = (s)->
            s.replace(/_([a-z])/g, ($0, $1)->
                $1.toUpperCase()
            )
        _._ = (s)->
            s.replace(/([^A-Z])([A-Z])/g, ($0, $1, $2)->
                $1 + "_" + $2.toLowerCase()
            )
    angularAMD
)
