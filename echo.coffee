request = require 'request'
_ = require 'lodash'

require('dotenv').load()


class EchoNestSong
  constructor: (@json) ->

  title: ->
    @json?.title

  artist_name: ->
    @json?.artist_name

  tracks: ->
    @json.tracks

  rdio_id: ->
    @rdio_track()?.foreign_id

  spotify_id: ->
    @spotify_track()?.foreign_id

  rdio_track: ->
    (track for track in @tracks() when track['catalog'] is "rdio-US")?[0]

  spotify_track: ->
    (track for track in @tracks() when @isSpotifyUS(track))?[0]

  isSpotifyUS: (track) ->
    track.foreign_id.match /spotify-US:track|spotify:track/

  peek: ->
    "#{@artist_name()} - #{@title()} (#{@rdio_id()}) (#{@spotify_id()})"



class EchoNest

  BASE_URL: 'http://developer.echonest.com/api/v4'

  BASE_PARAMS:
    api_key: process.env.ECHONEST_API_KEY
    format: 'json'
    results: 1

  constructor: ->

  find_song: (artist, title, callback) ->
    params = @_search_params(artist, title)
    results = @get {url: "#{@BASE_URL}/song/search", qs: params, }, (err, res, body) ->
      response = JSON.parse(body)?.response?.songs?[0]
      if response
        console.log (if body then new EchoNestSong(response).peek() else null)
      else
        console.log "ERROR: #{artist} #{title} #{body}"

  get: (options, callback) ->
    options_with_qs = _.extend {}, options, {
      qsStringifyOptions: { arrayFormat: 'repeat' }
    }
    request.get options_with_qs, callback

  _search_params: (artist, title) ->
    _.extend {}, @BASE_PARAMS, {
      artist: artist
      title: title
      bucket: ['tracks', 'id:spotify', 'id:rdio-US']
    }


echo = new EchoNest()
echo.find_song 'Sango', 'No one else'
echo.find_song "James Blake", "Love What Happened Here"
echo.find_song "Cardo", "Sunset"
echo.find_song "Bames", "Drty Bwty"
echo.find_song "Knope", "Love"
echo.find_song "Sun Glitters", "Too Much To Lose (Cracks Remix)"
echo.find_song "Robot Koch", "Glassdrops"
echo.find_song "Vindahl", "Down"
echo.find_song "Major Lazer", "Lean On (Feat. MO & DJ Snake)"
echo.find_song "Lapalux", "Gutter Glitter"
echo.find_song "Ladi6", "Shine On"
echo.find_song "Alizzz", "That Gurl"
echo.find_song "Ta-Ku", "Day 2"
