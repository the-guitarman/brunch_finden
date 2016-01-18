var initSearchField = function(){};
jQuery('document').ready(function($) {
    // search ------------------------------------------------------------------
    initSearchField = function(fieldSelector, formSelector, searchFieldDefaultValue, noSearchPhraseError) {
        $(fieldSelector).bind('focus', function() {
            var element = $(this);
            if (element.val().trim() == searchFieldDefaultValue) {
                element.val('');
            } else {
                $(formSelector).find('.text-message').remove();
            }
        });
        
        $(fieldSelector).bind('blur', function() {
            var element = $(this);
            if (element.val().trim() != searchFieldDefaultValue) {
                $(formSelector).find('.text-message').remove();
            }
        });
        
        $(formSelector).bind('submit', function() {
            //var element = $(this);
            var searchField = $(fieldSelector);
            if (searchField.val() == searchFieldDefaultValue || searchField.val().trim().length == 0) {
                if ($('.text-message').length == 0) {
                    $(this).append(noSearchPhraseError);
                }
                return false;
            } else {
                $(formSelector).find('.text-message').remove();
            }
        });
    };
    
    // infobox / errors --------------------------------------------------------
    $(document).on('click', '.mobile-adspace .close, .infobox .close', function(){
        var self = $(this);
        self.parents('.mobile-adspace, .infobox').slideUp('slow', function(){
            self.remove();
        });
    });
    
  
    // coupons -----------------------------------------------------------------
    $.fn.couponify = function() {
        var coupons = $(this).find('a.local');
        coupons.fancybox({
            autoDimensions: false,
            //cache: true,
            //content: '<div>Hello Welt!</div>',
            //cyclic: true,
            //href: couponUrl,
            margin: 0,
            //modal: true,
            overlayOpacity: 0.6,
            overlayColor: '#000',
            padding: 10,
            //title: self.attr('title') || 'Gutschein',
            //titlePosition: 'over',
            //titleFormat: function(title, currentArray, currentIndex, currentOpts) {
            //    return '<span id="fancybox-title-over">Gutschein ' + (currentIndex + 1) + ' von ' + currentArray.length + (title.length ? ' &nbsp; ' + title : '') +
            //    '</span>';
            //},
            transitionIn: 'elastic',
            transitionOut: 'elastic',
            type: 'ajax'//,
            //width: 790
        });
    };
    $('.coupon').couponify();
    
    
    // social plugin -----------------------------------------------------------
    $.fn.socialize = function(options) {
        if (!options) {options = {};}
        var socialPlugins = $(this).find('a');
        var loading = options.loading || '';
        socialPlugins.bind('click', function(){
            var self = $(this);
            if (loading.length > 0) {
                loading.showLoading(true);
            }
            $.ajax({
                type: 'GET',
                cache: true,
                url: self.attr('href'),
                //contentType: 'application/html; charset=utf-8', 
                //dataType: 'html',
                success: function(response, status, xhr) {
                    var ct = xhr.getResponseHeader('content-type') || '';
                    if (ct.indexOf('html') > -1) {
                        // handle html here
                        
                    } else if (ct.indexOf('json') > -1) {
                        // handle json here
                        //console.log('json returned');
                    } else {
                        //console.log('other returned');
                    }
                },
                error: function(xhr, ajaxOptions, thrownError) {
                    
                },
                complete: function (xhr, status) {
                    if (loading.length > 0) {
                        loading.hideLoading();
                    }
                    if (status === 'error' || !xhr.responseText) {
                        // handler error
                    } else {
                        
                    }
                }
            });
            return false;
        });
    };
    
    
    $.fn.ajaxifyForm = function() {
        //http://net.tutsplus.com/tutorials/javascript-ajax/uploading-files-with-ajax/
        var form = $(this);
        var inputFileField = form.find('input[type=file]');
        
        if (!window.FormData) {
            //form.find('.asterisk-note').parent().remove();
            //form.replaceWith('<div>Ihr Browser unterstützt leider noch keinen Datei-Upload via Ajax.</div>');
            return false;
        } else {
            form.find('#progress').show();
            //inputFileField.attr('multiple', 'multiple');
        }
            
        var progressBar = function(value) {
            $('#progress .bar.inner').css('width', value + '%');
            $('#progress .value').html(Math.round(value) + '%');
        };
      
        inputFileField.change(function(e) {
            $.each($(this)[0].files, function(i, file) {
                if (window.FileReader) {
                    progressBar(0);
                    var imagePreviewCt = $('#image-to-upload');
                    var reader = new FileReader();
                    if (!!file.type.match(/image.*/)) {
                        reader.onloadend = function (e) {
                            imagePreviewCt.find('img').attr('src', e.target.result);
                        };
                        reader.readAsDataURL(file);
                        imagePreviewCt.slideDown();
                    } else {
                        alert('Fehler: Die gewählte Datei ist kein Bild.');
                    }
                }
            });
        });
        
        var newPost = null;
        form.submit(function(){
            if (newPost) {newPost.abort();}
            var self = $(this);
            var data = self.serializeArray();
            var showLoadingCt = self.parent();
            if (showLoadingCt.parents('#fancybox-content').length > 0) {
                showLoadingCt = $('#fancybox-content');
            }
            
            var attributes = {
                type: 'POST',
                url: self.attr('action'),
                data: data,
                beforeSend: function() {
                    $('#fancybox-close').hide(); 
                    showLoadingCt.showLoading();
                },
                complete: function() {
                    $('#fancybox-close').show(); 
                    showLoadingCt.hideLoading();
                }
            };
            
            // http://www.solife.cc/blog/ajax-file-upload-formdata-xhr2.html
            if (self.attr('enctype') == 'multipart/form-data') {
                data = new FormData();
                self.find('input').each(function(idx, el) {
                    var element = $(el);
                    if (element.attr('type') == 'file') {
                        $.each(element[0].files, function(i, file) {
                            data.append(element.attr('name'), file);
                        });
                    } else if (element.attr('type') == 'checkbox' || element.attr('type') == 'radio') {
                        if (element.attr('checked') == 'checked') {
                            data.append(element.attr('name'), element.val());
                        }
                    } else if (element.attr('type') != 'submit') {
                        data.append(element.attr('name'), element.val());
                    }
                });
                
                var onProgress = function (data) {
                    var value = Math.round(data.loaded * 10000.0 / data.total) / 100.0;
                    //var value = parseInt(data.loaded / data.total * 100, 10);
                    progressBar(value);
                };
                
                // https://raw.github.com/davidmoreno/jquery-file-upload-progress/master/upload_progress.js
                // custom xhr
                attributes['xhr'] = function() {
                  var myXhr = $.ajaxSettings.xhr();
                  // check if upload property exists
                  if(myXhr.upload) {
                      // for handling the progress of the upload
                      myXhr.upload.addEventListener('progress', function(ev){onProgress(ev)}, false);
                  }
                  return myXhr;
                };
                attributes['processData'] = false;
                attributes['contentType'] = false;
                attributes['data'] = data;
            }
            
            newPost = $.ajax(attributes);
            return false;
        });
    };
    
    
    $('.show-details a').click(function(){
        var toggle = function(el) {
          $.each(['xs','sm','md','lg'], function(index, klass){
            if (el.hasClass('hidden-' + klass)) {
              el.removeClass('hidden-' + klass);
              el.addClass('visible-' + klass);
            } else if (el.hasClass('visible-' + klass)) {
              el.removeClass('visible-' + klass);
              el.addClass('hidden-' + klass);
            }
          });
        };

        var parent = $(this).parent();
        parent.find('a').toggleClass('hidden');
        toggle(parent.siblings());
    });
});