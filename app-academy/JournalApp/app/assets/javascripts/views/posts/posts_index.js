JournalApp.Views.PostsIndex = Backbone.View.extend({
  template: JST['posts/index'],
  initialize: function(options) {
    this.listenTo(this.collection, "add remove reset change:title", this.render);
  },
  events: {
    "click button": "deletePost"
  },
  deletePost: function(e) {
    e.preventDefault();
    console.log(e);

    // var payload = $(event.currentTarget).serializeJSON();
    // //var id = $(event.currentTarget).data("id");
    // var post = new JournalApp.Models.Post(payload.post);

    // post.destroy();
  },
  render: function(posts) {
    var renderedContent = this.template({
      title: "Posts Posts Posts",
      posts: this.collection
    });
    this.$el.html(renderedContent);
    return this;
  }
});
