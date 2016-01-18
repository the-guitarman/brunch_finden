jQuery('document').ready(function($) {
    $('#breadcrumb a').click(function(e){
        e.stopPropagation();
        e.stopImmediatePropagation();
    });
    $('#breadcrumb, a.toggle-breadcrumb').click(function(){
        var link = $('a.toggle-breadcrumb');
        var breadcrumb = $('#breadcrumb');
        if (link.is(':visible')) {
            link.slideUp('fast', function(){
                breadcrumb.slideDown('slow');
            });
        } else {
            breadcrumb.slideUp('fast', function(){
                link.slideDown('slow');
            });
        }
    });
});