currentUser = ->
  store = new Sammy.Store({name: 'hereandalive', element: 'body', type: 'local'})
  token = store.get('auth_token')
  email = store.get('email')

  auth_token: token
  email: email

storeCurrentUser = (email, auth_token) ->
  store = new Sammy.Store({name: 'hereandalive', element: 'body', type: 'local'})
  token = store.set('auth_token', auth_token)
  email = store.set('email', email)

app = $.sammy("#main", ->
  @use "Haml"
  @use "Session"

  # index: logged - hello, not logged - sign in/up
  @get "#/", (context) ->
    context.app.swap('')
    template = "/templates/index.haml"

    cu = currentUser()
    if cu.auth_token == "null" || cu.auth_token == null
      template = "/templates/index_unsigned.haml"

    context.render(template,
      currentUser: cu
    ).appendTo context.$element()

  # log off
  @get "#/sign_out", (context) ->
    storeCurrentUser(null, null)
    context.redirect("#/")

  # sign in
  @post "#/sign_in/submit", (context) ->
    email = @params['email']
    password = @params['password']
    hash =
      password: password
      email: email

    $.ajax(
      type: "POST"
      url: "/api/sign_in"
      data: hash
      dataType: "JSON"
    ).done( (d1) -> # user is in DB
      storeCurrentUser(email, d1['token'])
      context.redirect("#/")
    ).error( (d1) -> # error when sign in
      storeCurrentUser(null, null)
      context.redirect("#/")
    )

  # sign up
  @post "#/sign_up/submit", (context) ->
    email = @params['email']
    password = @params['password']
    hash =
      password: password
      email: email

    $.ajax(
      type: "POST"
      url: "/api/sign_up"
      data: hash
      dataType: "JSON"
    ).done( (d1) => # user created in DB
      context.redirect("#/sign_up/after")
    ).error( (d1) -> # cannot create user
      context.redirect("#/")
    )

  @get "#/sign_up/after", (context) ->
    context.app.swap('')
    context.render("/templates/sign_up/after.haml").appendTo context.$element()

    # $.ajax(
    #   type: "POST"
    #   url: "/api/sign_in"
    #   data: hash
    #   dataType: "JSON"
    # ).then ( (d1) -> # user is in DB
    #   alert(1)
    #   storeCurrentUser(email, d1['token'])
    #   context.redirect("#/")
    # ), ( (d1) -> # try to sign up
    #   alert(2)
    #   $.ajax(
    #     type: "POST"
    #     url: "/api/sign_up"
    #     data: hash
    #     dataType: "JSON"
    #   ).then (-> # user was created, execute sign in
    #     $.ajax(
    #       type: "POST"
    #       url: "/api/sign_in"
    #       data: hash
    #       dataType: "JSON"
    #     ).then ( (d3) -> # user is in DB, already sign in
    #       storeCurrentUser(email, d3['token'])
    #       context.redirect("#/")
    #     ), (-> # user created but cannot sign in
    #       alert("Internal error while signing in after sign up")
    #       context.redirect("#/")
    #     ), -> # deferred when trying to sign in previously signed up user
    #       console.log "D3 deferred"
    #       context.redirect("#/")
    #   ), (-> # user was not created
    #     alert("Error while sign up")
    #     context.redirect("#/")
    #   ), -> # deferred when trying to sign up
    #     console.log "D2 deferred"
    #     context.redirect("#/")
    # ), -> # deferred when trying to sign in
    #   alert(3)
    #   console.log "D1 deferred"
    #   context.redirect("#/")


  @get "#/profile", (context) ->
    cu = currentUser()

    $.ajax(
      url: "/api/profile"
      headers: {"X-Token": cu.auth_token}
    ).then ( (d) -> # profile can be loaded
      context.app.swap('')
      context.render("/templates/users/private.haml", {resource: d}).appendTo context.$element()
    ), (-> # profile cannot be loaded
      storeCurrentUser(null, null)
      context.redirect("#/")
    ), -> # deferred when trying to sign in previously signed up user
      console.log "Deferred"
      context.redirect("#/")

  @get "#/ping", (context) ->

    if navigator.geolocation
      navigator.geolocation.getCurrentPosition ((position) ->
        $("#lat").val( position.coords.latitude )
        $("#lon").val( position.coords.longitude )
        $("#accuracy").val( position.coords.accuracy )
        $("#altitude").val( position.coords.altitude )
        $("#altitudeAccuracy").val( position.coords.altitudeAccuracy )
        $("#heading").val( position.coords.heading )
        $("#speed").val( position.coords.speed )
      ), ((error) ->
        alert error.message
      ),
        enableHighAccuracy: true
        timeout: 5000

    cu = currentUser()
    context.app.swap('')
    context.render("/templates/ping.haml").appendTo context.$element()

  # submit current position and state (alive)
  @post "#/ping/submit", (context) ->
    cu = currentUser()

    hash =
      accuracy: @params.accuracy
      altitude: @params.altitude
      altitudeAccuracy: @params.altitudeAccuracy
      heading: @params.heading
      lat: @params.lat
      lon: @params.lon
      place: @params.place
      speed: @params.speed
      source: "js"
      location: @params.location

    $.ajax(
      type: "POST"
      url: "/api/ping"
      data: hash
      headers: {"X-Token": cu.auth_token}
      dataType: "JSON"
    ).then ( (d) -> # created ping
      console.log(d)
      context.redirect("#/ping/last")
    ), ( (d) -> # failed to create ping
      console.log "Error"
      context.redirect("#/ping")
    ), -> # deferred
      console.log "Deferred"
      context.redirect("#/ping")

    console.log(hash)

  @get "#/u/:public_handle", (context) ->
    console.log(context)

    $.ajax(
      url: "/api/u/" + context.params.public_handle
    ).then ( (d) -> # last ping can be loaded
      console.log(d)
      context.app.swap('')
      context.render("/templates/users/public.haml", {resource: d}).appendTo context.$element()
    ), (-> # last ping cannot be loaded
      context.redirect("#/")
    ), -> # last ping deferred
      console.log "Deferred"
      context.redirect("#/")

  @get "#/ping/last", (context) ->
    cu = currentUser()

    $.ajax(
      url: "/api/ping/last"
      headers: {"X-Token": cu.auth_token}
    ).then ( (d) -> # last ping can be loaded
      console.log(d)
      context.app.swap('')
      context.render("/templates/ping_show.haml", {resource: d}).appendTo context.$element()
    ), (-> # last ping cannot be loaded
      context.redirect("#/")
    ), -> # last ping deferred
      console.log "Deferred"
      context.redirect("#/")

  @get "#/ping/route", (context) ->
    cu = currentUser()

    $.ajax(
      url: "/api/ping"
      headers: {"X-Token": cu.auth_token}
    ).then ( (d) -> # last ping can be loaded
      console.log(d)
      context.app.swap('')
      context.render("/templates/ping_index.haml", {collection: d}).appendTo context.$element()
    ), (-> # last ping cannot be loaded
      context.redirect("#/")
    ), -> # last ping deferred
      console.log "Deferred"
      context.redirect("#/")

  # @post "#/sign_in/submit", (context) ->
  #   $.ajax(
  #     type: "POST"
  #     url: "/api/sign_in"
  #     data:
  #       password: @params['password']
  #       email: @params['email']
  #     dataType: "JSON"
  #   ).done (executeData) ->
  #     auth_token = executeData['token']
  #     store = new Sammy.Store({name: 'hereandalive', element: 'body', type: 'local'})
  #     store.set('auth_token', auth_token)
  #     store.set('email', @params['email'])
  #
  #     refreshProfile()
  #
  #     context.redirect("#/profile")
  #   .fail (executeData) ->
  #
  #     alert("Error while signing in")
  #     context.redirect("#/sign_in")

)



$ ->
  $('form').submit =>
    console.log this

  app.run "#/"
