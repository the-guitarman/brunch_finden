var simpleScrollTo = function(){}; 
jQuery(function($) {
    // Scroll to a dom node
    simpleScrollTo = function(nodeOrId, options) {
        if (!options) {options = {};}
        var onCompleteHandler = options.onCompleteHandler || function() {};
        var target = '';
        if ((typeof nodeOrId) == 'string') {
            if (nodeOrId.match(/^[^#]/)) {
                nodeOrId = '#' + nodeOrId;
            }
            // find element by id
            target = $(nodeOrId);
            if (target.length == 0) {
                // find element by name
                target = $('a[name="'+nodeOrId.slice(1)+'"]');
            }
        } else {
            target = $(nodeOrId);
        }
        if (target.length > 0) {
            var targetTop = target.offset().top - 50;
            var bodyEl = $('html,body');
            if ($.browser.webkit || $.browser.safari) {
                bodyEl = $('body');
            }
            bodyEl.animate({
                scrollTop: targetTop
            }, {
                duration: 500,
                easing: 'linear',
                complete: onCompleteHandler
            });
        }
    };

    // attaches a click handler to all <a> elements that have
    // the "#" symbol somewhere in their href attribute.
    $('a[href*=#]').bind('click', function () {
        // checks to make sure that the current page's path name (location.pathname) is
        // the same as the clicked link's path name (this.pathname) and the current page's host location (location.host) is
        // the same as the clicked link's host (this.host).
        // This ensures that the link is pointing to an item on the current page.
        if (
            location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') &&
            location.hostname == this.hostname
           ) {
            // find element by id (hash and everything that follows)
            var target = $(this.hash);
            if (target.length == 0) {
                // find element by name
                target = $('a[name="'+this.hash.slice(1)+'"]');
            }
            if (target.length == 1) {
                simpleScrollTo(target, {
                    onCompleteHandler: function() {
                        if ($.ui && typeof($.ui.effects) == 'function' && typeof($.ui.effects.highlight) == 'function') {
                            target.effect('highlight', {}, 1000);
                        }
                    }
                });
                return false;
            }
        }
    });
    
    
    // Scroll to top button
    $(window).scroll(function(){
        if ($(this).scrollTop() > 100) {
            $('.scrollup').fadeIn();
        } else {
            $('.scrollup').fadeOut();
        }
    });
    $('.scrollup').click(function(){
        $("html, body").animate({ scrollTop: 0 }, 600);
        return false;
    });
});