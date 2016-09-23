refreshProfile = ->
  $(".user-not-signed").hide()
  $(".user-signed").hide()

  store = new Sammy.Store({name: 'hereandalive', element: 'body', type: 'local'})
  token = store.get('auth_token')
  email = store.get('email')

  if token
    $(".user-signed").show()
    $(".user-not-signed").hide()

    $(".profile-email").innerHtml(email)
  else
    $(".user-signed").hide()
    $(".user-not-signed").show()



app = $.sammy("#main", ->
  @use "Haml"
  @use "Session"

  @get "#/", (context) ->
    context.app.swap('')
    context.render("/templates/index.haml",
    ).appendTo context.$element()

  @get "#/sign_up", (context) ->
    context.app.swap('')
    context.render("/templates/sign_up.haml",
    ).appendTo context.$element()

  @get "#/sign_in", (context) ->
    context.app.swap('')
    context.render("/templates/sign_in.haml",
    ).appendTo context.$element()

  @get "#/profile", (context) ->
    context.app.swap('')
    context.render("/templates/profile.haml",
      email: "Email"
    ).appendTo context.$element()

  @post "#/sign_up/submit", (context) ->
    $.ajax(
      type: "POST"
      url: "/api/sign_up"
      data:
        password: @params['password']
        email: @params['email']
      dataType: "JSON"
    ).done (executeData) ->

      context.app.swap('')
      context.render("/templates/post_sign_up.haml",
      ).appendTo context.$element()
      context.redirect("#/")
    .fail (executeData) ->

      alert("Error while signing up")
      context.redirect("#/sign_up")

  @post "#/sign_in/submit", (context) ->
    $.ajax(
      type: "POST"
      url: "/api/sign_in"
      data:
        password: @params['password']
        email: @params['email']
      dataType: "JSON"
    ).done (executeData) ->
      auth_token = executeData['token']
      store = new Sammy.Store({name: 'hereandalive', element: 'body', type: 'local'})
      store.set('auth_token', auth_token)
      store.set('email', @params['email'])

      refreshProfile()

      context.redirect("#/profile")
    .fail (executeData) ->

      alert("Error while signing in")
      context.redirect("#/sign_in")

)



$ ->
  $('form').submit =>
    console.log this

  app.run "#/"
