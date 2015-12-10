root = exports ? this

class Infotip

  setText: (text, element) ->
    $(element).qtip
      content: text
      position:
        corner:
          target: 'topRight'
          tooltip: 'bottomLeft'
      style:
        tip: true
        border:
          width: 0
          radius: 4
        name: 'light'
        width: 250

unless root.infotip
  root.infotip = new Infotip
