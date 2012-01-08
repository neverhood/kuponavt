// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery_ujs
//= require cufon
//= require transponder
//= require countdown
//= require cookie
//= require animate-colors
//= require api
//= require_tree .

if ( typeof $.api != 'undefined' ) {
    if ( typeof $.offers != 'undefined' ) $.api.offers = $.offers;
}


// Utils

$.api.utils.appendNotification = function(notification) {
    $( $.api.sections.notifications[ notification.type ] ).text( notification.text );
}

$.api.loader = function() { return $('#loader .loader').clone() } ;

Array.prototype.include = function(element) {
    for ( var i = 0; i <= this.length; i++ ) {
        if ( this[i] == element ) return true;
    }

    return false;
}

Array.prototype.equals = function(array) {
    if ( this.length != array.length )
        return false;

    for (var i = 0; i < this.length; i++) {
        if ( this[i] != array[i] ) return false;
    };

    return true;
}

Array.prototype.unique = function() {
    var uniqArray = [],
        length = this.length;

    for ( var i = 0; i < length; i++ ) {
        for ( var j = i+1; j < length; j++ ) {
            if ( this[i] === this[j] )
                j = ++i;
        }
        uniqArray.push(this[i]);
    }

    return uniqArray;
};

$('document').ready(function() {

    $('#kuponavt').click(function() {
        $.cookie( $.offers.cookies_key, null );
    });


    $.each( $('.time-left, .time-left-red'), function() {
        var $this = $(this);

        if ( $this.data('countdown') === undefined ) $this.countdown( new Date($this.text().trim()), { prefix: '', finish: 'Завершено' } )
    });

    $('#site-description-help').click( function() {
        $('div#site-description').show();
        $(this).addClass('high-opacity');
    });

    $('#site-description img.close-popup').click( function() {
        $('div#site-description').hide();
        $('img.help').removeClass('high-opacity');
    });

    $('img.close-popup').click(function() {
        $(this).parent().hide();
    });

});
