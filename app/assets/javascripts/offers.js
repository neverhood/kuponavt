// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$('document').ready(function() {

    $('.pagination a').live('ajax:complete', function( event, xhr, status ) {
        var attributes = $.parseJSON( xhr.responseText ),
            url = $(this).attr('href');

        $('#all-offers').html( attributes.offers );
        $('#pagination-bottom').html( attributes.pagination );

        Cufon.replace('.time-left');
        $("body").animate({ scrollTop: 25 }, 500);
    });

    $('#all-offers-check').hover(function() {
        $('#all-categories').toggleClass('hover');
    }).click(function(event) {
        event.preventDefault();
        event.stopPropagation();

        $('div#filter').find('input[type="checkbox"]').prop('checked', true);
    });

    $('#all-offers-clear').click(function(event) {
        event.preventDefault();
        event.stopPropagation();

        $('div#filter').find('input[type="checkbox"]').prop('checked', false);
    });

    $('span.all-tags').hover(function() {
        $(this).parent().next().toggleClass('hover');
    }).click(function() {
        var $this = $(this);
        if ( $this.data('checked-all') ) {
            $this.data('checked-all', !$this.data('checked-all'));
        } else {
            $this.data('checked-all', true);
        }
        $this.parent().next().find('input[type="checkbox"]').prop('checked', $this.data('checked-all'));
    });

    // Pjax
    //

//    $('.pagination a').pjax('[data-pjax-container]');

});
