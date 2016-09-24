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


# refreshProfile = ->
#   $(".user-not-signed").hide()
#   $(".user-signed").hide()
#
#   store = new Sammy.Store({name: 'hereandalive', element: 'body', type: 'local'})
#   token = store.get('auth_token')
#   email = store.get('email')
#
#   if token
#     $(".user-signed").show()
#     $(".user-not-signed").hide()
#
#     $(".profile-email").innerHtml(email)
#   else
#     $(".user-signed").hide()
#     $(".user-not-signed").show()


app = $.sammy("#main", ->
  @use "Haml"
  @use "Session"

  # index: logged - hello, not logged - sign in/up
  @get "#/", (context) ->
    context.app.swap('')
    template = "/templates/index.haml"

    cu = currentUser()
    if cu.auth_token == ""
      template = "/templates/index_unsigned.haml"

    context.render(template,
      currentUser: cu
    ).appendTo context.$element()

  # log off
  @get "#/sign_off", (context) ->
    storeCurrentUser("", "")
    context.redirect("#/")

  @post "#/sign_in/submit", (context) ->
    email = @params['password']
    password = @params['email']
    hash =
      password: email
      email: password

    $.ajax(
      type: "POST"
      url: "/api/sign_in"
      data: hash
      dataType: "JSON"
    ).done (d1) ->
      # user is in DB
      storeCurrentUser(email, d1['token'])
      context.redirect("#/")
    .fail (executeData) ->
      # try to sign up
      $.ajax(
        type: "POST"
        url: "/api/sign_up"
        data: hash
        dataType: "JSON"
      ).done (d2) ->
        # user was created, execute sign in
        $.ajax(
          type: "POST"
          url: "/api/sign_in"
          data: hash
          dataType: "JSON"
        ).done (d3) ->
          # user is in DB, already sign in
          storeCurrentUser(email, d3['token'])
          context.redirect("#/")
        .fail (d3) ->
          alert("Internal error while signing in after sign up")
          context.redirect("#/")
        .fail (d2) ->
          alert("Error while sign up")
          context.redirect("#/")


  ##################3
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
