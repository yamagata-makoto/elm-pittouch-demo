export class Promise

  ->
    @_thens = []
    @_reset-status!

  _reset-status: ->
    @_status =
      done: false
      args: undefined
      which: undefined

  then: (resolve, reject) ->
    @_thens.push resolve: resolve, reject: reject
    @_invoke-callback @_status

  resolve: ->
    @_complete 'resolve', arguments

  reject: ->
    @_complete 'reject', arguments

  _complete: (which, args) ->
    slice = Array.prototype.slice
    @_status =
      done: true
      args: slice.call(args)
      which: which
    @_invoke-callback @_status

  _invoke-callback: (status) ->
    if status.done and @_thens.length > 0
      @_reset-status!
      f = @_thens.shift![status.which]
      a = f.apply @, status.args
      if a instanceof Promise
        a.then (x) ~> @resolve x
      @resolve a
    return @
