// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$.offers = {
    latestCategoriesUpdate: [],
    offersPerPage: 25,
    latestSort: '',
    sections: {
        offers: '#offers-section',
        pagination: '#pagination-bottom',
        selectedCount: '#offers-selected-count'
    },
    utils: {}
}

$.offers.utils.showFavourites = function() {

    if ( $.cookie('favourites') ) {
        var offers = $.cookie('favourites').split(',');

        $.each( offers, function() {
            $('div#offer-' + this).find('.add-button').addClass('add-button-added');
        });
    }
}

$.offers.utils.city = function() {
    return $('#all-offers').attr('data-city');
}

$.offers.utils.page = function() {
    var currentPage = $('#pagination-bottom .current').text();

    return currentPage.length ? parseInt(currentPage) : 1;
}

$.offers.utils.checkedCategories = function() {
    return $.map($('#all-categories input[type="checkbox"]').
          filter(':checked'), function(element) { return element.id });
}

$.offers.utils.url = function(page) {
    var city = $.offers.utils.city(),
        checkedCategories = $.offers.utils.checkedCategories(),
        categories = [],
        url = '/' + city + '/offers';

    if ( page > 1 ) {
        url += '/' + page;
    }

    if ( checkedCategories.length ) {
        $.each( checkedCategories, function() {
            categories.push( parseInt(this) );
        });
        url += '?categories=' + categories.sort(function(a,b) { return a - b }).join(',');
    }

    if ( $( $.offers.sections.offers ).attr('data-sort-by') ) {
        var sortParams = $( $.offers.sections.offers ).attr('data-sort-by').split('|'),
            sortBy = sortParams[0],
            sortDirection = sortParams[1];

        url += ( '&sort[attribute]=' + sortBy + '&sort[direction]=' + sortDirection );
    }

    return url;
};

$.offers.utils.renderOffers = function(offers) {
    var offerTemplate = $('div#offer-id'),
        temporaryContainer = $('<div class="hidden"></div>').appendTo( $('body') );

    $.each( offers, function() {
        var offer = offerTemplate.clone().
            attr('id', this['id']).
            attr('data-category', this.category_id);
        offer.find('a.offer-url').attr('href', this.provider_url).text(this.title);
        offer.find('img.offer-image').attr('src', this.image_url);
        offer.find('td.offer-cost').text(this.cost);
        offer.find('td.offer-discount').text(this.discount + '%'); offer.find('td.offer-savings').text( this.cost ? this.cost/100 * this.discount : '' );
        offer.find('p.time-left').text(this.ends_at);
        offer.find('span.offer-price').text(this.price);
        offer.find('.subway-station').text(this.subway);

        temporaryContainer.append(offer);

    });

    var renderedOffers = temporaryContainer.find('.offer');
    temporaryContainer.remove();

    return renderedOffers;
}

$.offers.utils.offersAheadCount = function(categoryIds) {
    var count = 0;
        existingOffers = $('#offers-section div.offer'),
        existingOffersCategories = $.map( existingOffers, function(offer) {
            return parseInt( $(offer).attr('data-category') )
        }).unique();

    var counted = [];
    for (var i = 0; i < categoryIds.length; i++) {
        for (var j = 0; j < existingOffersCategories.length; j++) {
            if ( categoryIds[i] > existingOffersCategories[j] && !counted.include(existingOffersCategories[j]) ) { // j goes ahead of i
                counted.push( existingOffersCategories[j] );
                count += $('#offers-section div.offer[data-category="' + existingOffersCategories[j] + '"]').length;
            }
        };
    };

    return count;
}

$.offers.utils.changeCounterAndPaginate = function() {
    var totalSelectedOffersCount = $.offers.utils.selectedOffersCount();

    $.offers.utils.paginate( totalSelectedOffersCount );
    $('#offers-selected-count').text( totalSelectedOffersCount );
}

$.offers.utils.retrieveOffers = function(page) { // Retrieves offers, count and pagination
    $('div.loader').show(50);
    $('#current-offers-count').append( $.api.loader() );

    $('.notification').hide();

    var checkedCategories = $.offers.utils.checkedCategories();
    if ( checkedCategories.length ) {
        $.getJSON($.offers.utils.url(page), function(data) {
            $( $.offers.sections.offers ).html( data.offers );
            // $( $.offers.sections.offers ).html( $.offers.utils.renderOffers( $.parseJSON( data.offers ) ) );

            if ( page > 1 ) {
                $( $.offers.sections.pagination ).html( data.pagination );
                $( $.offers.sections.selectedCount ).html( data.count );
            } else {
                $.offers.utils.changeCounterAndPaginate();
            }

            Cufon.replace('.time-left');
            $('#current-offers-count').find('.loader').remove();
            $.offers.utils.showFavourites();
        });
    } else {
        $('#all-offers').find('.loader').remove();
        $('#offers-section').find('.offer').remove();
        $.offers.utils.changeCounterAndPaginate();
    }
}

$.offers.utils.getOffers = function(categoryIds) { // Retrieves just offers
    $('.notification').hide();

    if ( $( $.offers.sections.offers ).attr('data-sort-by') ) {
        $.offers.utils.retrieveOffers( $.offers.utils.page() );
        return false;
    }

    // This craziness was crafted to reproduce the server ORDER BY logic
    // It allows us to avoid redundant ajax requests
    var selectedCategories = $('#all-categories').find('input[type="checkbox"]').filter(':checked'),
        selectedCategoryIds = $.map(selectedCategories, function(category) { return parseInt(category.id) });

    if ( categoryIds.equals( selectedCategoryIds ) ) {
        $( $.offers.sections.offers ).html('');
        $( $.offers.sections.pagination ).html('');
    }

    var offersAheadCount = $.offers.utils.offersAheadCount(categoryIds),
        totalSelectedOffersCount = $.offers.utils.selectedOffersCount(),
        existingOffers = $('#offers-section div.offer');

    if ( offersAheadCount >= $.offers.offersPerPage ) { // No need to get any offers, they wouldn't fit into page anyway. just simulate
        $('#offers-selected-count').text( totalSelectedOffersCount );
        $.offers.utils.paginate( totalSelectedOffersCount );
    } else if (categoryIds.length > 1 && offersAheadCount > 0 && offersAheadCount != $.offers.offersPerPage) {
        // Too complex, just get offers from server
        $.offers.utils.retrieveOffers(1);
    } else {
        var url = '/' + $.offers.utils.city() + '/offers?categories=' + categoryIds.join(',');
        $('#current-offers-count').append( $.api.loader() );

        $.getJSON( url, function(data) {
            var offers = data.offers; //).filter('div.offer');
            // var offers = $.offers.utils.renderOffers( $.parseJSON(data.offers) );
            if ( existingOffers.length == 0 ) {
                $( $.offers.sections.offers ).append( offers );
            } else {
                if ( offersAheadCount == 0 ) {
                    if ( offers.length == $.offers.offersPerPage ) {
                        $( $.offers.sections.offers ).html('').append( offers );
                    } else {
                        $( $.offers.sections.offers ).prepend( offers );
                    }
                } else {
                    var offerToInsertAfter = existingOffers.slice( offersAheadCount - 1, offersAheadCount );
                    offerToInsertAfter.after( offers );
                }

                var updatedOffers = $('#offers-section div.offer');
                updatedOffers.slice($.offers.offersPerPage, updatedOffers.length).remove();
            }
            Cufon.replace('.time-left');
            $('#current-offers-count').find('.loader').remove();
            $.offers.utils.paginate( totalSelectedOffersCount );
            $.offers.utils.showFavourites();
        });
    }

    $('#offers-selected-count').text( totalSelectedOffersCount );
}

$.offers.utils.selectedOffersCount = function() {
    var categories = $('#all-categories').find('input[type="checkbox"]').filter(':checked'),
        totalCount = 0;

    $.each( categories, function() {
        totalCount += parseInt( $(this).parent().next().text().replace(/\D/g, '') );
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

        $.each( template.find('a'), function() {
            this.href = this.href + ',' + $.offers.utils.checkedCategories().join('|');
        });

        paginationContainer.html( template );
    }

}

$('document').ready(function() {

    $('.pagination a').live('ajax:complete', function( event, xhr, status ) {
        var attributes = $.parseJSON( xhr.responseText ),
            url = this.href;

        $('#offers-section').html( attributes.offers );
        $('#pagination-bottom').html( attributes.pagination );

        $("body").animate({ scrollTop: 25 }, 500);
    });

    $('.pagination a').live({
        click: function(event) {
            if ( /#/.test(this.href) ) {
                event.preventDefault();
                event.stopPropagation();

                var params = this.href.replace(/^.*#/, '').split(','),
                    page = params[0];
                if ( params.length == 2 ) {
                    categories = params[1].split('|').join(',');
                }

                $.offers.utils.retrieveOffers(page);
                $("html:not(:animated)"+( ! $.browser.opera ? ",body:not(:animated)" : "")).animate({scrollTop: 25}, 500);
            }
        }
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
                $.offers.utils.retrieveOffers(1);
            }
        }
    });

    $('#all-offers-clear').click(function(event) {
        event.preventDefault();
        event.stopPropagation();

        $('#offers-selected-count').text('0');

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

            if ( $.offers.utils.page() == 1 ) {
                var categoryIds = $.map( checkboxes, function(category) { return parseInt(category.id) } );

                if ( check ) {
                    $.offers.utils.getOffers( categoryIds );
                } else {
                    var count = 0;
                    $.each( categoryIds, function(id) {
                        count += $('#offers-section div.offer[data-category="' + categoryIds[id] + '"]').length
                    });

                    if ( count > 0 ) {
                        $.offers.utils.retrieveOffers(1);
                    } else {
                        $.offers.utils.changeCounterAndPaginate();
                    }
                }
            } else {
                $.offers.utils.retrieveOffers(1);
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

        if ( $.offers.utils.page() == 1 ) {
            if ( checked ) {
                $.offers.utils.getOffers( [parseInt( this.id )] );
            } else {
                if ( $('#offers-section div.offer[data-category="' + this.id + '"]').length > 0 ) {
                    $.offers.utils.retrieveOffers(1);
                } else {
                    $.offers.utils.changeCounterAndPaginate();
                }
            }
        } else {
            $.offers.utils.retrieveOffers(1);
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

    if ( $('#sort-by-category_id').length ) {
        $('#sort-by-category_id').data('sort', 'desc').
            addClass('current-sort').
            append( '<span class="desc"></span>' );
    }

    $('#sort-buttons li').click(function() {
        var $this = $(this),
            ul = $this.parent();

        if ( $('#all-categories input[type="checkbox"]').filter(':checked').length > 0 ) {
            inverseSortDirection = function(direction) {
                return ( direction == 'asc' ? 'desc' : 'asc' );
            };

            ul.find('li').removeClass('current-sort');
            ul.find('.asc, .desc').remove();

            $this.addClass('current-sort');

            if ( $.offers.latestSort == this.id )
                $this.data('sort', inverseSortDirection( $this.data('sort') ));
            else $this.data('sort', 'asc');

            var sortBy = this.id.replace('sort-by-', ''),
                direction = $this.data('sort');

            $('#offers-section').attr('data-sort-by', sortBy + '|' + direction );

            $.offers.latestSort = this.id;
            $this.append('<span class="' + $this.data('sort') + '"></span>');

            $.offers.utils.retrieveOffers(1);
        } else {
            $('#sort-buttons .notification').show();
        }
    });

    // $('#sort-reset').click(function() {
    //     if ( $( $.offers.sections.offers ).attr('data-sort-by') ) {
    //         var sortButtons = $('ul.sort-buttons');

    //         sortButtons.find('.asc, .desc').remove();
    //         sortButtons.find('li').removeClass('current-sort');

    //         $.offers.latestSort = '';
    //         $( $.offers.sections.offers ).removeAttr('data-sort-by');

    //         $.offers.utils.retrieveOffers(1);
    //     }
    // });

    // Favourites

    if ( /\/offers\/favourites/.test(window.location.href) && $.cookie('favourites') ) {
        var favouritedOffers = $.cookie('favourites');

        $.getJSON( '/offers/favourites?offers=' + $.cookie('favourites'), function(data) {
            var countContainer = $('#offers-selected-count');

            $( $.offers.sections.offers ).append( data.offers );

            countContainer.append( $.api.loader() );
            countContainer.text( data.count );
            countContainer.find('.loader').remove();

            $.offers.utils.showFavourites();

            $('div.offer div.add-button-added').bind('click', function(event) {
                var addedOffers = $.cookie('favourites').split(','),
                    offer = $(this).parents('div.offer'),
                    offerId = offer.attr('id').replace('offer-', ''),
                    index = addedOffers.indexOf(offerId),
                    currentCount = parseInt( countContainer.text() );

                if ( index != -1 ) {
                    addedOffers.splice(index, 1);
                    $.cookie( 'favourites', addedOffers.unique(), { expires: 7, path: '/' } );
                    offer.fadeOut();
                    countContainer.text( currentCount - 1 );
                }

                event.preventDefault();
                event.stopPropagation();
            });
        });
    }

    $.offers.utils.showFavourites();

    $('div.offer div.add-button').live({
        click: function() {
            var $this = $(this),
            offerId = $this.parents('div.offer').attr('id').replace('offer-', ''),
            options = { expires: 7, path: '/' };

            if ( $.cookie('favourites') ) {
                var addedOffers = $.cookie('favourites').split(',');

                if ( addedOffers.include(offerId) ) {
                    var index = addedOffers.indexOf(offerId);

                    if ( index != -1 ) addedOffers.splice(index, 1);
                    $this.removeClass('add-button-added');

                } else {
                    addedOffers.push(offerId);
                    $this.addClass('add-button-added');
                }
                $.cookie( 'favourites', addedOffers.unique(), options );

            } else {
                $.cookie( 'favourites', offerId, options );
                $this.addClass('add-button-added');
            }

        }
    });

});
