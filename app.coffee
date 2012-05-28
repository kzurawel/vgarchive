# Module dependencies
express = require 'express'
mongoose = require 'mongoose'
path = require 'path'

app = module.exports = express.createServer()

mongoose.connect 'mongodb://localhost/vgarchive'

# Configuration

app.configure ->
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static path.join(__dirname, '/public')
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

  # Schema configuration

GameModel = mongoose.model 'Game', new mongoose.Schema
  title:
    type: String
    required: true
  system:
    type: String
    required: true
  genre:
    type: [String]
    required: true


# Routes

app.get '/api', (req, res) ->
  res.send 'VGArchive API is running'

app.get '/api/games', (req, res) ->
  GameModel.find (err, games) ->
    if not err
      return res.send games
    else
      return console.log err

app.post '/api/games', (req, res) ->
  console.log "POST: "
  console.log req.body
  game = new GameModel
    title: req.body.title
    system: req.body.system
    genre: req.body.genre
  game.save (err) ->
    if not err
      return console.log "created"
    else
      return console.log err
  res.send game

app.get '/api/games/:id', (req, res) ->
  GameModel.findById req.params.id, (err, game) ->
    if not err
      return res.send game
    else
      return console.log err

app.put '/api/games/:id', (req, res) ->
  GameModel.findById req.params.id, (err, game) ->
    game.title = req.body.title
    game.system = req.body.system
    game.genre = req.body.genre
    game.save (err) ->
      if not err
        console.log "updated"
      else
        console.log err
      res.send game

app.delete '/api/games/:id', (req, res) ->
  GameModel.findById req.params.id, (err, game) ->
    game.remove (err) ->
      if not err
        console.log "removed"
      else
        console.log err

app.listen 3000
console.log "Express server listening on port %d", app.address().port
