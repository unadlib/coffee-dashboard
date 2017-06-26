define(['angularAMD'],(angularAMD)->
    angularAMD.factory('fCat',['restmod','Fields','fLabel'
        (restmod,Fields,fLabel)->
            model = restmod.model('{domain}/other/cat','restmod.Preload','DirtyModel')
            model.mix({
                label:
                    belongsTo:'fLabel'
                    key:'label'
                $hooks:
                    'after-fetch-many':->
                        @$field = @.$build().$field

                $field:
                    init:
                        Fields.fCat

            })

            model
    ])
    .factory('fLabel',['restmod',
        (restmod)->
            model = restmod.model('{domain}/other/label')
            model
    ])
    .factory('fPromise',['restmod','Fields'
        (restmod,Fields)->
#            factoryTable.$config.primaryKey = 'id'
            model = restmod.model('{domain}/api/menu')
            model.mix({
                $config:
                    primaryKey:'ruleId'
                $hooks:
                    'after-fetch-many':->
                        @$field = @$build().$field
                $field:
                    init:
                        Fields.fPromise
            })
            model
    ])
)
