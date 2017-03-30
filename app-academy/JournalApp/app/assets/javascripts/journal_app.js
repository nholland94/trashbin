window.JournalApp = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: function() {
    JournalApp.posts = new JournalApp.Collections.Posts();
    
    var post = new JournalApp.Models.Post({
      title: "New Post 1",
      body: "asdfasdfdafsdasdf",
      id: 1
    });

    JournalApp.posts.add(post);


    new JournalApp.Routers.Posts();
    Backbone.history.start();

  }
};

$(document).ready(function(){
  JournalApp.initialize();
});
