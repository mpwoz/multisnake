#
# Snake game
#



snakeArtist = (ctx) ->

  snakeid = ""
  setId = (id) ->
    snakeid = id

  clearScreen = () ->
    ctx.fillStyle = "rgba(0,0,0, .5)"
    ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height)

  drawSquare = (coords, color, sqSize) ->
    ctx.fillStyle = color
    ctx.fillRect(coords[0] * sqSize, coords[1] * sqSize, sqSize, sqSize)

  drawSnake = (sqSize) ->
    return (id, snake) ->
      color = if snakeid is id then 'rgb(0,255,119)' else 'rgb(173,173,173)'
      drawSquare snake.head, color, sqSize
      for b in snake.body
        drawSquare b, color, sqSize

  drawBerry = (sqSize) ->
    return (berry) ->
      drawSquare berry, 'rgb(255,0,0)', sqSize

  drawState = (st, sqSize) ->
    clearScreen()

    ds = drawSnake sqSize
    ds id, snake for id, snake of st.snakes

    db = drawBerry sqSize
    db berry for berry in st.berries
  

  exportFunctions =
    setId: setId
    draw: drawState
  return exportFunctions





snakeGame = (ctx) ->

  artist = snakeArtist ctx
  boundary = sqSize = null

  setId = (id) ->
    artist.setId id

  updateSettings = (settings) ->
    boundary = settings.boundary
    sqSize = ctx.canvas.width / boundary


  drawState = (state) ->
    artist.draw state, sqSize


  exportFunctions =
    setId: setId
    updateSettings: updateSettings
    drawState: drawState
  return exportFunctions



setupSockets = (game, socket) ->
  socket.on 'welcome', (data) ->
    game.setId data.id
    console.log 'Connected! Id is: ' + data.id
    console.log ' Message from server: ' + data.message
    socket.emit 'request settings'

  # Receiving game specific settings from server
  socket.on 'game settings', ( settings ) ->
    game.updateSettings settings

  socket.on 'gamestate broadcast', (gamestate) ->
    console.log 'Receiving new gamestate from server'
    game.drawState gamestate

  return (message, data) ->
    socket.emit message, data


setupInput = (sendMessage) ->
  # Listen for key presses to turn the snake
  window.addEventListener('keydown', (event) ->
    key = event.keyCode
    if (37 <= key <= 40)
      direction = switch key
        when 37 then "left"
        when 38 then "up"
        when 39 then "right"
        when 40 then "down"
      sendMessage 'change direction', direction
  )


$( () ->
  host = '#{ host }'
  socket = io.connect host

  canvas = document.getElementById 'game-area'
  ctx = canvas.getContext '2d'

  game = snakeGame ctx
  sendMessageHandler = setupSockets game, socket
  setupInput sendMessageHandler
)


