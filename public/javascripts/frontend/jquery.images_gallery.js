//jQuery('document').ready(function($) {
jQuery(function($) {
    $.fn.initImagesGallery = function(autostart, hideControlls) {
        var galleries = $(this);
        galleries.find('img').removeAttr('alt').removeAttr('title');
              
        $(document).on('click', '.ad-gallery .ad-image-wrapper .ad-image img', function(){
          var img = $('.fancybox-images img[src="' + window.location.origin + $(this).attr('src') + '"]');
          if (img.length > 0) {
              img.parent().trigger('click');
          }
        });

        galleries = galleries.adGallery({
          update_window_hash: false,
          display_next_and_prev: true,
          display_back_and_forward: true,
          slideshow: {
              enable: true,
              autostart: autostart,
              speed: 20000
          },
          callbacks: {
              init: function(){
                  this.preloadAll();
              }
          }
        });
        galleries[0].nav.hide();
        if (hideControlls == true) {
          galleries[0].controls.hide();
          galleries[0].next_link.hide();
          galleries[0].prev_link.hide();
        }
    };
});