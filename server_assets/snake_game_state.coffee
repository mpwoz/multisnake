##
#
# The server-side representation of a game of MultiSnake
#
##



# Game variables
berries = []
NUM_BERRIES = 10
BOUNDARY = 50
snakes = {}

OPPOSITES =
  left: 'right'
  right: 'left'
  up: 'down'
  down: 'up'



randomCoord = -> Math.floor(Math.random() * BOUNDARY + 1)
randomSquare = -> [randomCoord(), randomCoord()]

spawnBerry = ->
  return randomSquare()

killSnake = (id) ->
  resetPlayer id


checkBerries = (x, y) ->
  for i, berry of berries
    if (berry[0] is x) and (berry[1] is y)
      berries.splice i, 1
      return true
  return false

updateSnake = (id, s) ->
  x = s.head[0]
  y = s.head[1]

  # Don't hit the edges!
  if not (0 < x < BOUNDARY) or not (0 < y < BOUNDARY)
    killSnake id
    return id
  
  # Don't eat yourself!
  for b in s.body
    if (s is b[0]) and (y is b[1])
      killSnake id
      return id

  berryEaten = checkBerries x, y

  s.body.unshift(s.head) # push the head to the front of the snake
  if not berryEaten
    s.body.pop() # remove the tail we didn't eat food
  s.head =
    switch s.direction
      when "left" then [x-1, y]
      when "right" then [x+1, y]
      when "up" then [x, y-1]
      when "down" then [x, y+1]

  # Allow more direction input
  s.directionChanged = false

updateGameState = ->
  # Update players' positions
  # IDs of dead snakes will be returned
  deaths = updateSnake i,s for i,s of snakes

  # Respawn any eaten berries
  while NUM_BERRIES - berries.length
    berries.push spawnBerry()
  
    #TODO
  return deaths


broadcastGameState = (io) ->
  # Send player and berry positions to everyone
  gamestate =
    snakes: snakes
    berries: berries
  io.sockets.volatile.emit 'gamestate broadcast', gamestate


gameLoop = (io) ->
  return ->
    updateGameState()
    broadcastGameState(io)


createNewPlayer = ->
  head = randomSquare()
  body = [[head[0]-1, head[1]]]
  player =
    head: head
    body: body
    direction: 'right'
    directionChanged: false
    alive: true
  return player


addPlayer = (id) ->
  snakes[id] = createNewPlayer()
  console.log ' [SNAKE] Added player ' + id

removePlayer = (id) ->
  delete snakes[id]
  console.log ' [SNAKE] Removed player ' + id

resetPlayer = (id) ->
  removePlayer id
  addPlayer id


updateDirection = (id, direction) ->
  snake = snakes[id]
  return if snake.directionChanged

  old = snake.direction
  return if (OPPOSITES[old] is direction)

  snake.direction = direction
  snake.directionChanged = true




setSocketHandlers = (io) ->
  io.sockets.on 'connection', (socket) ->
    addPlayer socket.id
    socket.emit 'welcome', 'message': 'Welcome to MultiSnake!'

    socket.on 'request settings', (data) ->
      socket.emit 'game settings', boundary: BOUNDARY

    socket.on 'change direction', (data) ->
      updateDirection socket.id, data

    socket.on 'disconnect', ->
      removePlayer socket.id



# Starts a brand new game of MultiSnake
exports.newGame = ( io ) ->
  setSocketHandlers io

  intervalId = setInterval gameLoop(io), 300
  # clearInterval intervalId
  # to stop calling this game loop



