$(document).on('turbolinks:load', function() {
  NProgress.remove()

  NProgress.configure({ trickleRate: 0.025, trickleSpeed: 100 });

  $(document).on('ajax:send turbolinks:click', function() {
    NProgress.start()
  }).on('ajax:complete turbolinks:render', function() {
    NProgress.done()
  });
});
