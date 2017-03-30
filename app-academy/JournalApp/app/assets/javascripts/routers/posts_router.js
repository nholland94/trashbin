JournalApp.Routers.Posts = Backbone.Router.extend({
  routes: {
    "": "showPostsIndex",
    "posts/:id": "showPostDetail",
    "post/new": "showPostForm"
  },

  showPostsIndex: function() {
    var indexView = new JournalApp.Views.PostsIndex({
      collection: JournalApp.posts
    });

    indexView.render();
    $(".main").html(indexView.$el);
  },
  showPostDetail: function(id) {
    var showView = new JournalApp.Views.PostShow({
      model: JournalApp.posts.get(id)
    });

    showView.render(id);
    $(".main").html(showView.$el);
  },
  showPostForm: function() {
    var formView = new JournalApp.Views.NewPost({});

    formView.render();
    $(".main").html(formView.$el);
  }
});
