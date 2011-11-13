// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$('document').ready(function() {

    $('.pagination a').live('ajax:complete', function( event, xhr, status ) {
        var attributes = $.parseJSON( xhr.responseText );
        $('#all-offers').html( attributes.offers );
        $('#pagination-top').html( attributes.pagination );
    });

});
