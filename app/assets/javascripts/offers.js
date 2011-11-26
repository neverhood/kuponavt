// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$.offers = {
    latestCategoriesUpdate: [],
    sections: {
        offers: '#all-offers',
        pagination: '#pagination-bottom',
        selectedCount: '#offers-selected-count'
    },
    utils: {}
}

$.offers.utils.city = function() {
    return $('#all-offers').attr('data-city');
}

$.offers.utils.checkedCategories = function() {
    return $.map($('#all-categories input[type="checkbox"]').
          filter(':checked'), function(element) { return element.id });
}

$.offers.utils.url = function() {
    var city = $.offers.utils.city(),
        categories = $.offers.utils.checkedCategories().join(','),
        url = '/' + city + '/offers';
    if ( categories.length ) {
        return url + '?categories=' + categories;
    } else {
        return url;
    }
};

$.offers.utils.renderOffers = function(offers) {
    $('#all-offers').html('');
    var offerTemplate = $('div#offer-id'),
        allOffersContainer = $('#all-offers');

    $.each( offers, function() {
        var offer = offerTemplate.clone().
            attr('id', this['id']).
            attr('data-category', this.category_id);
        offer.find('a.offer-url').attr('href', this.url).text(this.title);
        offer.find('img.offer-image').attr('src', this.image_url);
        offer.find('td.offer-cost').text(this.cost);
        offer.find('td.offer-discount').text(this.discount);
        offer.find('td.offer-savings').text( this.cost ? this.cost/100 * this.discount : '' );
        offer.find('p.time-left').text(this.ends_at);
        offer.find('span.offer-price').text(this.price);

        allOffersContainer.append( offer );
    });
}

$.offers.utils.retrieveOffers = function() {
    $.offers.latestCategoriesUpdate = $.offers.utils.checkedCategories();

    $('div.loader').show(50);

    $.getJSON($.offers.utils.url(), function(data) {

        $( $.offers.sections.offers ).html( data.offers );
        $( $.offers.sections.pagination ).html( data.pagination );
        $( $.offers.sections.selectedCount ).html( data.count );

        Cufon.replace('.time-left');
        $('div.loader').hide();
    });
}

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
        $.offers.utils.retrieveOffers();
    });

    $('#all-offers-clear').click(function(event) {
        event.preventDefault();
        event.stopPropagation();

        $('div#filter').find('input[type="checkbox"]').prop('checked', false);
        $.offers.utils.retrieveOffers();
    });

    $('span.all-tags').hover(function() {
        $(this).parent().next().toggleClass('hover');
    }).click(function() {
        var $this = $(this);

        if ( typeof $this.data('checked-all') != 'undefined' ) {
            $this.data('checked-all', !$this.data('checked-all'));
        } else {
            $this.data('checked-all', true);
        }
        $this.parent().next().find('input[type="checkbox"]').prop('checked', $this.data('checked-all'));
        $.offers.utils.retrieveOffers();
    });

    // Offer-bottom-more

    $(".offer-bottom").live('click', function(){
        $(this).prev().toggle('1s');
    });



    // Categories

    $('#all-categories input[type="checkbox"]').change(function() {
        var $this = $(this),
            checked = $this.prop('checked');

        $.offers.utils.retrieveOffers();
    });

    // Search
    //
    
    $('#search_field').bind({
        focus: function() {
            if ( this.value == $(this).attr('data-value') ) this.value = '';
        },
        blur: function() {
            if ( this.value.length == 0 ) {
                $(this).val( $(this).attr('data-value') );
            }
        }
    });



//    $('.pagination a').pjax('[data-pjax-container]');

});
