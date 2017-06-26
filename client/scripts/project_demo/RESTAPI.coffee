angular.module('restmod').factory('AMSApi',[
    'restmod', 'inflector','$injector','factoryTable'
    (restmod,inflector,$injector,factoryTable)->
        delete factoryTable.$extend.Model.encodeName
        restmod.mixin('DefaultPacker',factoryTable)
])
