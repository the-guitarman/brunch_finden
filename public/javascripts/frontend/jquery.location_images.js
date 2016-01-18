jQuery(function($) {
    $.fn.applyLightBox = function() {
        $(this).fancybox({
            overlayOpacity: 0.6,
            overlayColor: '#000',                                
            transitionIn: 'elastic',
            transitionOut: 'elastic',
            titlePosition: 'inside' //,
            //onComplete: function() {
            //    
            //}
        });
    };    
    $('a.lightbox').applyLightBox();
});