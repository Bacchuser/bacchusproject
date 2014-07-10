MAP_CONTAINER = "#map-container";

#
# Wrapper for a google map position. This wrapper is optimized to
# manipulate one and only one marker (it is a singleton).
# This allow us to be time efficient, and maintain a code quiet readable.
#
class Position
  # Singleston instance.
  @_instance: null
  # The map where our position is plot
  _gg_map: null
  # The google map marker.
  _marker: null
  # A list of the events already used. This way we can not
  # overwrite some events.
  _events: []

  constructor: (gg_map) ->
    this._gg_map = gg_map
    this._marker = new google.maps.Marker { map: this._gg_map, draggable: true }

  # Give the current position of the marker
  get_position: () -> this._marker.getPosition()
  # Delegate lat and lng from the google map API
  lat: () -> this._marker.getPosition().lat()
  lng: () -> this._marker.getPosition().lng()

  # Allow to add a listener only once by event_name.
  # no overwrite or change of listener are allowed.
  add_listener: (event_name, fct) ->
    return if event_name in this._events
    this._events.push event_name
    google.maps.event.addListener this._marker,
      event_name,
      fct

  # set the google map position
  set_position: (lat, lng) ->
    this._marker.setPosition new google.maps.LatLng lat, lng

  # classic singleton getter.
  @getInstance: (gg_map) ->
    if @_instance == null
      @_instance = new Position(gg_map)
    @_instance

#
# A geoencode engine is launch, listening to change
# over input.
#
class GeoEncoderListener
  _encoder: new google.maps.Geocoder()
  _ville: $(MAP_CONTAINER).find(".map-container.ville")
  _rue: $(MAP_CONTAINER).find(".map-container.rue")
  _pays: $(MAP_CONTAINER).find(".map-container.pays")
  _button_refresh: $(MAP_CONTAINER).find(".btn.geo-refresh")

  _last_update: $.now()
  _gg_map = null

  @delta_time = 1000

  constructor: (gg_map) ->
    this._gg_map = gg_map
    this._ville.on('change', { this_obj : this }, this.encode)
    this._rue.on('change', { this_obj : this }, this.encode)
    this._pays.on('change', { this_obj : this }, this.encode)
    this._button_refresh.on('click', { this_obj : this }, this.force_encode)

  force_encode: (event) ->
    this_obj = event.data.this_obj
    this_obj._last_update = this_obj._last_update - GeoEncoderListener.delta_time
    this_obj.encode(event)
    false

  encode: (event) ->
    this_obj = event.data.this_obj
    return false if ! this_obj.can_encode()
    console.log "encoding started"
    this_obj._last_update = $.now()
    this_obj._encoder.geocode { address: this_obj._get_address() },
      (results, status) ->
        if status == google.maps.GeocoderStatus.OK
          location = results[0].geometry.location
          console.log "STATUS OK, geoencoding found", results[0].geometry.location
          set_cursor(this_obj._gg_map, location.lat(), location.lng())
        else
          alert 'Geocode was not successful for the following reason: ' + status
    false

  can_encode: () ->
    time_spent = $.now() - this._last_update
    console.log "can encode ? "
    console.log "Time : " + this._last_update + ", spent : " + time_spent
    console.log time_spent >= GeoEncoderListener.delta_time
    time_spent >= GeoEncoderListener.delta_time

  _get_address: () ->
    address = []
    ville = this._ville.val()
    rue = this._rue.val()
    pays = this._pays.val()
    address.push(ville) if ville != ""
    address.push(rue) if rue != ""
    address.push(pays) if pays != ""
    return address.join(", ")

# Global value for the script.
# The different containers are stored, and the map object is keep
# just in case.
map_container = document.getElementById("map-canvas")
lat_container = $(MAP_CONTAINER).find(".row .map-container.lat")
lng_container = $(MAP_CONTAINER).find(".row .map-container.lng")


#
# Method to set the cursor on the map.
#
set_cursor = (gg_map, lat, lng, zoom = 14) ->
  console.log ">> set_cursor"
  position = Position.getInstance(gg_map)
  position.set_position lat, lng

  gg_map.setZoom(zoom)
  gg_map.setCenter(position.get_position())
  lat_container.val lat
  lng_container.val lng
  position.add_listener 'dragend',
    () ->
      pos = Position.getInstance(gg_map)
      lat_container.val pos.lat()
      lng_container.val pos.lng()

#
# The values of the text fields have changed.
#
listener_lat_lng = () ->
  lat = lat_container.val()
  lng = lng_container.val()
  set_cursor map, lat, lng, 12
# Apply the listener.
lat_container.on 'change', listener_lat_lng
lng_container.on 'change', listener_lat_lng

#
# Load a google maps view in the #map-canvas container.
# Try to center by default on the current location, using HTML5.
# If user does not allow us to access his position, we put
# an hard-coded location.
#
launch_map = (center) ->
  console.log ">> launch_map"

  #
  # Callback when the HTML5 succeed to find the user current position.
  # This function initialised the map with the position.
  # Custom position could be givent, through the default_position callback for
  # example.
  #
  success_position = (position) ->
    console.log ">> success_position"
    set_cursor(map, position.coords.latitude, position.coords.longitude)

  #
  # Define a default and hard-coded location.
  #
  default_position = () ->
    console.log ">> default_position"
    success_position( { coords: { latitude: 46.5173566, longitude: 6.6291100 } } )

  #
  # Callback when the HTML5 API raised an exception.
  # We log the exception and fallback by default position.
  #
  error_position = (error) ->
    console.log ">> error_position"
    switch error.code
      when error.PERMISSION_DENIED
        console.log "L'utilisateur n'a pas autorisé l'accès à sa position"
      when error.POSITION_UNAVAILABLE
        console.log "L'emplacement de l'utilisateur n'a pas pu être déterminé"
      when error.TIMEOUT
        console.log "Le service n'a pas répondu à temps"
    default_position()

  if navigator.geolocation # The HTML5 location API exists
    console.log ">> navigator.geolocation HTML5"
    navigator.geolocation.getCurrentPosition(success_position, error_position)
  else
    console.log ">> NO navigator.geolocation HTML5"
    default_position()


map = new google.maps.Map map_container,
  { scrollwheel: false, mapTypeId: google.maps.MapTypeId.ROADMAP}

console.log ">> Start tasks.js.coffee"
google.maps.event.addDomListener(window, 'load', launch_map)
new GeoEncoderListener(map)
