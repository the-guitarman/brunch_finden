jQuery('document').ready(function($) {
    var rememberCheckboxes = $('.all-city-locations .col-remember input[type=checkbox]');
    if (rememberCheckboxes.length > 0) {
        rememberCheckboxes.removeClass('hidden');

        var locationComparison = $('.location-comparison');
        locationComparison.hide().removeClass('hidden');
        
        var compareLocationValuesFn = function() {
            var values = ($.cookie('compareLocationValues') || '').trim();
            values = ((values.length > 0) ? values.split(';') : []);
            return values;
        };
        
        var values = compareLocationValuesFn();
        if (values.length > 1) {
            locationComparison.find('.counter').html(values.length);
            $.each(values, function(idx, elId) {
                $(elId).attr('checked', 'checked');
            });
            locationComparison.fadeIn('slow');
        }

        rememberCheckboxes.click(function(e){
            var self = $(this);
            var values = compareLocationValuesFn();
            if (self.attr('checked') == 'checked') {
                if ($.inArray(self.attr('id'), values) == -1) {
                    values.push(self.attr('id'));
                }
            } else {
                var idx = $.inArray(self.attr('id'), values);
                if (idx > -1) {
                    values.splice(idx, 1);
                }
            }
            if (locationComparison.length > 0) {
                if (values.length > 1) {
                    locationComparison.fadeIn('slow');
                } else {
                    locationComparison.fadeOut('slow');
                }
                locationComparison.find('.counter').html(values.length);
            }
            $.cookie('compareLocationValues', values.join(';'));
        });
        
        locationComparison.find('a.compare').click(function(e){
            var values = compareLocationValuesFn();
            var ids = $.map(values, function(val, i) {
              return 'ids[]=' + val;
            });
            if (ids.length > 0) {
                ids = '?' + ids.join('&');
            } else {
                ids = '';
            }
            $.fancybox({
                autoDimensions: false,
                //cache: true,
                //content: '<div>Hello Welt!</div>',
                //cyclic: true,
                href: '/locations/compare' + ids,
                height: 590,
                //modal: true,
                overlayOpacity: 0.6,
                overlayColor: '#000',
                //title: self.attr('title') || 'Gutschein',
                //titlePosition: 'over',
                //titleFormat: function(title, currentArray, currentIndex, currentOpts) {
                //    return '<span id="fancybox-title-over">Gutschein ' + (currentIndex + 1) + ' von ' + currentArray.length + (title.length ? ' &nbsp; ' + title : '') +
                //    '</span>';
                //},
                transitionIn: 'elastic',
                transitionOut: 'elastic',
                type: 'ajax',
                width: 790
            });
            return false;
        });

        locationComparison.find('a.reset').click(function(e){
            $.cookie('compareLocationValues', '');
            rememberCheckboxes.removeAttr('checked');
            locationComparison.find('.counter').html('0');
            locationComparison.
              delay(1000, "compareLocationQueue").
              queue("compareLocationQueue", function(){ 
                  locationComparison.fadeOut('slow', function(){
                      locationComparison.fadeOut('slow');
                  });
              }).
              dequeue("compareLocationQueue");
            return false;
        });
    }
});