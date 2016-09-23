// Generated by CoffeeScript 1.10.0
(function() {
  var app, refreshProfile;

  refreshProfile = function() {
    var email, store, token;
    $(".user-not-signed").hide();
    $(".user-signed").hide();
    store = new Sammy.Store({
      name: 'hereandalive',
      element: 'body',
      type: 'local'
    });
    token = store.get('auth_token');
    email = store.get('email');
    if (token) {
      $(".user-signed").show();
      $(".user-not-signed").hide();
      return $(".profile-email").innerHtml(email);
    } else {
      $(".user-signed").hide();
      return $(".user-not-signed").show();
    }
  };

  app = $.sammy("#main", function() {
    this.use("Haml");
    this.use("Session");
    this.get("#/", function(context) {
      context.app.swap('');
      return context.render("/templates/index.haml").appendTo(context.$element());
    });
    this.get("#/sign_up", function(context) {
      context.app.swap('');
      return context.render("/templates/sign_up.haml").appendTo(context.$element());
    });
    this.get("#/sign_in", function(context) {
      context.app.swap('');
      return context.render("/templates/sign_in.haml").appendTo(context.$element());
    });
    this.get("#/profile", function(context) {
      context.app.swap('');
      return context.render("/templates/profile.haml", {
        email: "Email"
      }).appendTo(context.$element());
    });
    this.post("#/sign_up/submit", function(context) {
      return $.ajax({
        type: "POST",
        url: "/api/sign_up",
        data: {
          password: this.params['password'],
          email: this.params['email']
        },
        dataType: "JSON"
      }).done(function(executeData) {
        context.app.swap('');
        context.render("/templates/post_sign_up.haml").appendTo(context.$element());
        return context.redirect("#/");
      }).fail(function(executeData) {
        alert("Error while signing up");
        return context.redirect("#/sign_up");
      });
    });
    return this.post("#/sign_in/submit", function(context) {
      return $.ajax({
        type: "POST",
        url: "/api/sign_in",
        data: {
          password: this.params['password'],
          email: this.params['email']
        },
        dataType: "JSON"
      }).done(function(executeData) {
        var auth_token, store;
        auth_token = executeData['token'];
        store = new Sammy.Store({
          name: 'hereandalive',
          element: 'body',
          type: 'local'
        });
        store.set('auth_token', auth_token);
        store.set('email', this.params['email']);
        refreshProfile();
        return context.redirect("#/profile");
      }).fail(function(executeData) {
        alert("Error while signing in");
        return context.redirect("#/sign_in");
      });
    });
  });

  $(function() {
    $('form').submit((function(_this) {
      return function() {
        return console.log(_this);
      };
    })(this));
    return app.run("#/");
  });

}).call(this);
