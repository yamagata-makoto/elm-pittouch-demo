export Felica =
  system-code: 'FFFF'
  use-masterIDm: true

export Suica =
  system-code: '0003'
  use-masterIDm: true
  service: [
    service-code: '090F'
    block: 20
  ]

export Sapica =
  system-code: '865E'
  use-masterIDm: true
  service: [
    service-code: '090F'
    block: 20
  ]

export class PittouchPro
  ->
    @op = new ProOperate!

    @touch-either-handler = (response-object) ~>
      if response-object.param-result > 0
      then @touch-handler response-object
      else @error-handler response-object

    @touch-handler = (response-object) -> undefined
    @release-handler = -> undefined
    @error-handler = (response-object) -> undefined

    @param =
      success-sound: '/pjf/sound/success.wav'
      fail-sound: '/pjf/sound/fail.wav'
      success-lamp: 'BB0N'
      fail-lamp: 'RR0N'
      wait-lamp: 'BG1L'
      felica: []
      mifare: []
      onetime: true
      on-event: (event-code, response-object) ~>
        if event-code
        then @touch-either-handler response-object
        else @release-handler!

  set-success-lamp: (pattern-string) ->
    @param.success-lamp = pattern-string

  set-fail-lamp: (pattern-string) ->
    @param.fail-lamp = pattern-string

  set-wait-lamp: (pattern-string) ->
    @param.wait-lamp = pattern-string

  map-felica: (f) -> @param.felica = f @param.felica
  map-mifare: (f) -> @param.mifare = f @param.mifare

  set-touch-handler: (f) -> @touch-handler = f
  set-release-handler: (f) -> @release-handler = f
  set-error-handler: (f) -> @error-handler = f

  play-sound: (path, loop_=false, on-event=(event-code) ->) ->
    @op.play-sound file-path: path loop: loop_ on-event: on-event

  stop-sound: (sound-id) ->
    @op.stop-sound soundID: sound-id

  start-communication: ->
    @op.start-communication @param

  stop-communication: ->
    @op.stop-communication!

  get-terminal-id: ->
    @op.get-terminalID!

  get-contents-version: ->
    @op.get-contents-set-version!

  get-network-stat: ->
    @op.get-network-stat!

  reboot: ->
    @op.reboot!

  shutdown: ->
    @op.shutdown!

