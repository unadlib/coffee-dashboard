define(['app','toastr'],(app,toastr)->
    app.factory('logger',->
        toastr.options =
            "closeButton": true
            "positionClass": "toast-bottom-right"
            "timeOut": "3000"

        logIt = (message, type,title,options) ->
            toastr[type](message,title,options)

        return {
            log: (message,title,options) ->
                logIt(message, 'info',title,options)
                return

            logWarning: (message,title,options) ->
                logIt(message,'warning',title,options)
                return

            logSuccess: (message,title,options) ->
                logIt(message, 'success',title,options)
                return

            logError: (message,title,options) ->
                logIt(message, 'error',title,options)
                return
        }
    )


)









