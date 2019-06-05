$(document).on('turbolinks:load', function() {
  NProgress.remove()

  NProgress.configure({ trickleRate: 0.025, trickleSpeed: 100 });

  $(document).on('ajaxStart turbolinks:click', function() {
    NProgress.start()
  }).on('ajaxStop turbolinks:render', function() {
    NProgress.done()
  });
});
