app = $.sammy("#main", ->
  @use "Haml"

  @get "#/", (context) ->
    context.app.swap('')
    context.render("/templates/index.haml",
    ).appendTo context.$element()

  @get "#/sign_up", (context) ->
    context.app.swap('')
    context.render("/templates/sign_up.haml",
    ).appendTo context.$element()

  @post "#/sign_up/submit", (context) ->
    alert(@params)

    $.ajax(
      type: "POST"
      url: "/api/sign_up/"
      data:
        password: @params['password']
        email: @params['email']
      dataType: "JSON"
    ).done (executeData) ->
      alert(1)
      context.app.swap('')
      context.render("/templates/post_sign_up.haml",
      ).appendTo context.$element()
)

$ ->
  $('form').submit =>
    console.log this

  app.run "#/"
