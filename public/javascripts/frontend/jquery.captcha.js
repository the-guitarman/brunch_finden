jQuery('document').ready(function($) {
    // load/reload captcha images
    $.fn.applyCaptcha = function(url) {
        var captcha = $(this);
        captcha.hide();
        $.ajax({
            url: url,
            success: function(data) {
                captcha.html(data);
                captcha.slideDown('slow');
            }
        });
    };

    //captcha.on('click', 'a.reload-captcha', function() {
    $(document).on('click', 'a.reload-captcha', function (e) {
        var self = $(this);
        var captcha = self.parents('.captcha').first();
        captcha.showLoading();
        $.ajax({
            url: self.attr('href'),
            success: function(data) {
                captcha.slideUp('fast', function() {
                    captcha.replaceWith(data);
                    captcha.slideDown('slow');
                    captcha.removeClass('checked');
                    captcha.removeClass('error');
                });
            },
            complete: function() {
                captcha.hideLoading();
            }
        });
        return false;
    });
});