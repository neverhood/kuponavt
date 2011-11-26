// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$.offers = {
    latestCategoriesUpdate: [],
    offersPerPage: 25,
    latestSort: '',
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
        checkedCategories = $.offers.utils.checkedCategories(),
        categories = [],
        url = '/' + city + '/offers';

    if ( checkedCategories.length ) {

        $.each( checkedCategories, function() {
            categories.push( parseInt(this) );
        });

        return url + '?categories=' + categories.sort(function(a,b) { return a - b }).join(',');
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

$.offers.utils.retrieveOffers = function() { // Retrieves offers, count and pagination
    $('div.loader').show(50);

    $.getJSON($.offers.utils.url(), function(data) {

        $( $.offers.sections.offers ).html( data.offers );
        $( $.offers.sections.pagination ).html( data.pagination );
        $( $.offers.sections.selectedCount ).html( data.count );

        Cufon.replace('.time-left');
        $('div.loader').hide();
    });
}

$.offers.utils.getOffers = function(categoryIds) { // Retrieves just offers
    var url = '/' + $.offers.utils.city() + '/offers?categories=' + categoryIds,
        offersContainer = $( $.offers.sections.offers ),
        categoriesCount = $('#all-categories').find('input[type="checkbox"]').filter(':checked').length, // Checked categories
        existentOffers;

    if ( categoriesCount == 1 ) { // No categories selected ( besides of `this` one )
        existentOffers = [];
    } else {
        existentOffers = $('div.offer');
    }

    $.getJSON(url, function(data) {
        var offers = $(data.offers).filter('div.offer'),
            offersCount = offers.length,
            existentOffersCount = existentOffers.length,
            offersToRemoveCount,
            totalOffersCount = $.offers.utils.selectedOffersCount();

        if ( existentOffersCount == 0 || offersCount >= 25 ) offersContainer.html('');

        if ( $.offers.offersPerPage < ( offersCount + existentOffersCount ) && offersCount < 25 ) { // Need to delete some offers to free space for new ones
           existentOffers.slice( ($.offers.offersPerPage - offersCount), existentOffers.length ).remove();
        }

        offersContainer.prepend( data.offers ); // And celebrate!
        $('#offers-selected-count').text( totalOffersCount );
        $.offers.utils.paginate( totalOffersCount );
    });
}

$.offers.utils.selectedOffersCount = function() {
    var categories = $('#all-categories').find('input[type="checkbox"]').filter(':checked'),
        totalCount = 0;

    $.each( categories, function() {
        totalCount += parseInt( $(this).parent().next().text().replace(/\D/, '') );
    });

    return totalCount;
}

$.offers.utils.paginate = function(offersCount) {
    var rawCount = offersCount/$.offers.offersPerPage,
        template = $('.pagination-template').clone().removeClass('pagination-template'),
        pagesCount = ( rawCount > parseInt( rawCount ) ) ? (parseInt( rawCount ) + 1) : rawCount,
        paginationContainer = $('#pagination-bottom').html('');

    if ( pagesCount > 1 ) {
        $.each( template.find('.page'), function() {
            var $this = $(this);

            if ( typeof $this.find('a').attr('data-page') != 'undefined' ) {
                if ( parseInt( $this.find('a').attr('data-page') ) > pagesCount ) {
                    $this.remove();
                }
            }
        });
        var lastPage = template.find('.last').find('a');
        lastPage.attr('href', lastPage.attr('href').replace('LAST_PAGE', pagesCount));

        paginationContainer.html( template );
    }

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

    $('#all-offers-check').bind({
        hover: function() {
            $( $.offers.sections.offers ).toggleClass('hover');
        },
        click: function(event) {
            event.preventDefault();
            event.stopPropagation();

            var checkboxes = $('div#filter').find('input[type="checkbox"]');
            if ( checkboxes.length != checkboxes.filter(':checked').length ) {
                checkboxes.prop('checked', true)
                $.offers.utils.retrieveOffers();
            }
        }
    });

    $('#all-offers-clear').click(function(event) {
        event.preventDefault();
        event.stopPropagation();

        $('div#filter').find('input[type="checkbox"]').prop('checked', false);
        $( $.offers.sections.offers ).html('');
        $( $.offers.sections.pagination ).html('');
    });

    $('span.all-tags').bind({
        hover: function() {
            $(this).parent().next().toggleClass('hover');
        },
        click: function() {
            var $this = $(this),
                ul = $this.parent().next(),
                checkboxes = ul.find('input[type="checkbox"]'),
                check = true;

            if ( checkboxes.filter(':checked').length == checkboxes.length ) check = false;

            checkboxes.prop('checked', check)

            if ( check ) {
                var categoryIds = $.map( checkboxes, function(category) { return category.id } );

                $.offers.utils.getOffers( categoryIds.join(',') );
            } else {
                $.offers.utils.retrieveOffers();
            }
        }
    });

    // Offer-bottom-more

    $(".offer-bottom").live('click', function(){
        $(this).prev().toggle('1s');
    });



    // Categories

    $('#all-categories input[type="checkbox"]').change(function() {
        var $this = $(this),
            checked = $this.prop('checked');

        if ( checked ) {
            $.offers.utils.getOffers(this.id);
        } else {
            $.offers.utils.retrieveOffers();
        }
    });

    // Search
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

    // Sort

    $('#sort-buttons li').click(function() {
        var $this = $(this),
            ul = $this.parent(),
            inverseSortDirection = function(direction) {
                return ( direction == 'asc' ? 'desc' : 'asc' );
            };

        ul.find('li').removeClass('current-sort');
        ul.find('.asc, .desc').remove();

        $this.addClass('current-sort');

        if ( $.offers.latestSort == this.id ) {
            $this.data('sort', inverseSortDirection( $this.data('sort') ));
        } else {
            $this.data('sort', 'asc')
        }

        $.offers.latestSort = this.id;

        $this.append('<span class="' + $this.data('sort') + '"></span>');

    });

});
