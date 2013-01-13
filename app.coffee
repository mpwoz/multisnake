express = require 'express'
stylus = require 'stylus'
routes = require './routes'
socketio = require 'socket.io'

app = express.createServer()
io = socketio.listen(app)




# assuming io is the Socket.IO server object
io.configure ->
  io.set("transports", ["xhr-polling"])
  io.set("polling duration", 10)
  io.set 'log level', 1




app.use express.logger {format: ':method :url :status :response-time ms'}
app.use require("connect-assets")()
app.set 'view engine', 'jade'
app.use express.static(__dirname + '/public')

# Routes
app.get '/', routes.index

snake = require './server_assets/snake_game_state'
snake.newGame(io)

# Start the server
port = process.env.PORT or 3000
app.listen port, -> console.log "Listening on port " + port

