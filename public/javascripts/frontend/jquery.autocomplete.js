var cacheSearchSuggestion = {}, lastSearchSuggestionsXhr = null;
jQuery(function($) {
    $.widget("custom.globalSearch", $.ui.autocomplete, {
        _renderMenu: function(ul, items) {
            var self = this, currentType = "";
            $.each(items, function(index, item) {
                if (item.category != currentType) {
                    ul.append("<li class='ui-autocomplete-type'>" + item.category + "</li>");
                    currentType = item.category;
                }
                self._renderItem(ul, item);
            });
        },

        _renderItem: function(ul, item) {
            return $("<li></li>")
                .data("item.autocomplete", item)
                .append("<a><table><tr><td class='suggested-label'>"+item.label+"</td></tr></table></a>").appendTo(ul);
        }
    });
    
    $.widget("custom.localSearch", $.ui.autocomplete, {
        _renderMenu: function(ul, items) {
            var self = this;
            $.each(items, function(index, item) {
                self._renderItem(ul, item);
            });
        },

        _renderItem: function(ul, item) {
            return $("<li></li>")
                .data("item.autocomplete", item)
                .append("<a><table><tr><td class='suggested-label'>"+item.label+"</td></tr></table></a>").appendTo(ul);
        }
    });
    
    $("#search-field").globalSearch({
        appendTo: '#search-suggestions',
        html: true,
        //source: location.protocol + '//' +location.host + '/search/suggestions'
        source: function(request, response) {
            if (lastSearchSuggestionsXhr){
                lastSearchSuggestionsXhr.abort();
            }

            var term = request.term;
            if (term in cacheSearchSuggestion) {
                response(cacheSearchSuggestion[term]);
                return;
            }

            lastSearchSuggestionsXhr = $.ajax({
              url: location.protocol + '//' +location.host + '/suchvorschlaege', 
              dataType: 'json',
              data: request,
              success: function(data, status, xhr) {
                  cacheSearchSuggestion[term] = data;
                  if (xhr === lastSearchSuggestionsXhr) {
                      response(data);
                  }
                  lastSearchSuggestionsXhr = null;
              },
              complete: function(data, status, xhr){
                  
              }
            });
              
            /*
            $.getJSON(
                location.protocol + '//' +location.host + '/suchvorschlaege', 
                request, 
                function(data, status, xhr) {
                    cacheSearchSuggestion[term] = data;
                    if (xhr === lastSearchSuggestionsXhr) {
                        response(data);
                    }
                    lastSearchSuggestionsXhr = null;
                }
            );
            */
        },

        select: function (event, ui){
            window.location.href = ui.item.url;
            //console.debug(ui['item'])
            //console.debug(ui.item.url)
        }
    });
});