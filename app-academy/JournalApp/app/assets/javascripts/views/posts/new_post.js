JournalApp.Views.NewPost = Backbone.View.extend({
  template: JST['posts/form'],
  events: {
    "submit form": "submitPost"
  },
  submitPost: function(e) {
    e.preventDefault();
    var title = $(this.el).find('input[name="title"]').val();
    var body = $(this.el).find('input[name="body"]').val();
    var id = JournalApp.posts.models[JournalApp.posts.models.length - 1].id + 1;

    var post = new JournalApp.Models.Post({
      title: title,
      body: body,
      id: id
    });

    JournalApp.posts.add(post);

    Backbone.history.navigate("/", {trigger: true});
  },
  render: function(posts) {
    var renderedContent = this.template({});
    this.$el.html(renderedContent);
    return this;
  }
});
