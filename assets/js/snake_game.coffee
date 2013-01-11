#
# Snake game
#
#
gameLoop = (ctx) ->

  # Number of pixels per grid square
  sqSize = 5
  boundary = ctx.canvas.width / sqSize

  # x, y components of a direction vector
  direction = "right"


  snake = [[4,3], [3,3], [2,3], [1,3]]
  head = [5, 3]

  berries = []
  numBerries = 100
  berryEaten = false

  score = 0


  directionChangedThisFrame = false

  # Spawns a random berry
  spawnBerry = () ->
    x = Math.floor(Math.random() * boundary + 1)
    y = Math.floor(Math.random() * boundary + 1)
    berries.push([x,y])
 
  eatBerry = (i, berry) ->
    if head[0] is berry[0] and head[1] is berry[1]
      berryEaten = true
      berries.splice(i, 1)
      score++

    
  # Makes sure all the berries are spawned, and eaten if necessary
  updateBerries = () ->
    eatBerry(i, berry) for i, berry of berries

    # Respawn the eaten berries
    spawnBerry() while numBerries - berries.length


  # TODO: code duplication
  reset = () ->
    direction = "right"
    snake = [[4,3], [3,3], [2,3], [1,3]]
    head = [5, 3]
    berries = []
    berryEaten = false
    score = 0

    
  # Handles movement and death of snake
  updateSnake = () ->
    x = head[0]
    y = head[1]
     
    # Don't hit the edges!
    if not (0 < x < boundary) or not (0 < y < boundary)
      return reset()
    
    for sec in snake
      if (x is sec[0]) and (y is sec[1])
        return reset()

    snake.unshift(head) # push the head to the front of the snake
    if not berryEaten
      snake.pop() # remove the tail we didn't eat food
    else berryEaten = false

    # Where will the new head be?
    head =
      switch direction
        when "left" then [x-1, y]
        when "right" then [x+1, y]
        when "up" then [x, y-1]
        when "down" then [x, y+1]

    directionChangedThisFrame = false

  # Handles drawing a single "square" of the snake
  drawSection = (section) ->
    ctx.fillStyle = "rgb(255,255,255)"
    ctx.fillRect(section[0] * sqSize, section[1] * sqSize, sqSize, sqSize)
  
  drawBerry = (berry) ->
    ctx.fillStyle = "rgb(255,0,0)"
    ctx.fillRect(berry[0] * sqSize, berry[1] * sqSize, sqSize, sqSize)



  # Listen for key presses to turn the snake
  window.addEventListener('keydown', (event) ->
    key = event.keyCode

    if (37 <= key <= 40) and not directionChangedThisFrame
      directionChangedThisFrame = true

      direction = "left"  if key is 37 unless direction is "right"
      direction = "up"    if key is 38 unless direction is "down"
      direction = "right" if key is 39 unless direction is "left"
      direction = "down"  if key is 40 unless direction is "up"


    console.log( "Keypress: " + event.keyCode \
      + " New direction = " + direction )
  )


  # repeat for each frame
  return () ->
    # Update the snake's position
    updateSnake()

    updateBerries()
    
    # Clear screen, not completely opaque for some fading effect
    ctx.fillStyle = "rgba(0,0,0, .5)"
    ctx.fillRect(0, 0, ctx.canvas.width, ctx.canvas.height)

    # Draw the snake
    drawSection head
    drawSection section for section in snake

    drawBerry berry for berry in berries

    




$( () ->
  canvas = document.getElementById 'game-area'
  ctx = canvas.getContext '2d'

  setInterval(gameLoop(ctx), 60)

)


