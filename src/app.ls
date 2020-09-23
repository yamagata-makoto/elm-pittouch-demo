# patch for Elm
Object.define-property XMLHttpRequest.prototype, 'response',
  get: -> @responseText


# --| Main
window.add-event-listener 'DOMContentLoaded', ->
  //
  -- エントリポイント
  //
  { PittouchPro, Suica, Sapica, Felica } = require './contrib/pittouch-pro'
  { Elm } = require './elm'

  pittouch = new PittouchPro
  pittouch.map-felica (_) ~> [Suica, Sapica, Felica]
  pittouch.set-wait-lamp 'BG1L'

  flags =
    ver: pittouch.get-contents-version!

  { flags: flags, node: document.get-element-by-id "body" }
    |> Elm.Main.init
    |> (bootstrap pittouch)
    |> (.start-communication!)


# --| Bootstrap
bootstrap = (pittouch, elm) -->
  //
  -- イベントハンドラ等の設定
  //
  pittouch.set-touch-handler (info) ->
    # カードタッチ(近接)
    info.date = (new Date).get-time!
    console.log (JSON.stringify info)
    elm.ports.touchEvent.send info.idm

  pittouch.set-release-handler ->
    pittouch.start-communication!

  pittouch.set-error-handler (_) ->
    # カードタッチ(異常)
    pittouch.play-sound "./snd/error.wav"
    pittouch.start-communication!

  return pittouch
