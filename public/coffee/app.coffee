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
)

$ ->
  app.run "#/"
