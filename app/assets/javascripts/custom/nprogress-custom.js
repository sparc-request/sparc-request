$(document).on('turbolinks:load', function() {
  NProgress.remove()

  NProgress.configure({ trickleRate: 0.025, trickleSpeed: 100 });

  $(document).on('ajaxSend ajax:send turbolinks:click', function(event) {
    if (event.target.tagName != 'A' || event.target.getAttribute('href').charAt(0) !== '#')
      NProgress.start();
  }).on('ajaxComplete ajax:complete turbolinks:render', function() {
    NProgress.done()
  });
});
