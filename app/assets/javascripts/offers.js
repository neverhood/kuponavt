// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$.offers = {
    offersPerPage: 25,
    latestSort: '',
    sections: {
        offers: '#offers-section',
        pagination: '#pagination-bottom',
        selectedCount: '#offers-selected-count'
    },
    utils: {},
    cookies_key: 'kuponavt_params',
    cookies: {
        sort: 'category_id desc',
        categories: 'all',
        time_period: 0,
        page: 1
    },
    cookies_changed: false
};

$.offers.utils.setCookies = function() {
    var cookies = $.offers.cookies,
        string = cookies.sort + '|' + cookies.categories + '|' + cookies.time_period + '|' + cookies.page;

    $.cookie( $.offers.cookies_key, string, { expires: 7 } );
};

$.offers.utils.copyCookies = function() {
    var params = $.cookie( $.offers.cookies_key ).split('|');

    $.offers.cookies = {
        sort: params[0],
        categories: params[1],
        time_period: params[2],
        page: params[3]
    }
};

$.offers.utils.setCookie = function(key, value) {
    $.offers.cookies[key] = value;
    $.offers.utils.setCookies();
}

$.offers.utils.startCountDown = function() {
    $.each( $('.time-left, .time-left-red'), function() {
        var $this = $(this);

        if ( $this.data('countdown') === undefined ) $this.countdown( new Date($this.text().trim()), { prefix: '', finish: 'Завершено' } )
    });
};

$.offers.utils.toggleOptions = function() {
    var options = [ $('#lenses'), $('#sort-buttons') ];

    var shownOffersCount = parseInt( $('#offers-selected-count').text() ),
        selectedOffersCount = $.offers.utils.selectedOffersCount(),
        timePeriod = parseInt( $( $.offers.sections.offers ).attr('data-time_period') ),
        lense;

    if ( timePeriod === 0 ) lense = $('#all-lens');
    if ( timePeriod == 1 ) lense = $('#today-lens');
    if ( timePeriod == 2 ) lense = $('#yesterday-lens');

    $.each( options, function() {
        ( selectedOffersCount > 0 ) ? this.show() : this.hide();
    });

    $('#no-results-found').hide();

    if ( options[1].is(':visible') ) {
        $('#no-results-to-display').hide();
    } else {
        $('#no-results-to-display').show();
    }

    if ( shownOffersCount == 0 && timePeriod != 0 && selectedOffersCount > 0 ) {
        //$('.time-period-tag').remove();
        options[1].hide();

        var info = $('#no-results-for-time-period');

        if ( info.not(':visible') ) info.show();

        if ( info.find('.time-period-tag').length == 0 ) {
          info.append('<span class="time-period-tag">' + lense.text() + '</span>.').
               append('<p>Попробуйте выбрать другой временной промежуток</p>').
               show();
        } else {
          info.find('.time-period-tag').replaceWith('<span class="time-period-tag">' + lense.text() + '</span>');
        }

    } else {
        $('#no-results-for-time-period').hide();
    }
}

$.offers.utils.rememberCategories = function() {
    $.offers.cookies.categories = $.offers.utils.checkedCategories().join(',');
    $.offers.cookies.page = false;
    $.offers.utils.setCookies();
};

$.offers.utils.showFavourites = function() {

    if ( $.cookie('favourites') ) {
        var offers = $.cookie('favourites').split(',');

        $.each( offers, function() {
            $('div#offer-' + this).find('.add-button').addClass('add-button-added');
        });
    }
};

$.offers.utils.city = function() {
    return $('#all-offers').attr('data-city');
};

$.offers.utils.showLenses = function() {
    var lenses = $('#lenses');

    if ( lenses.not(':visible') && $.offers.utils.selectedOffersCount() > 0 ) {
        lenses.show();
    }
};

$.offers.utils.hideLenses = function() {
    var lenses = $('#lenses');

    if ( lenses.is(':visible') ) {
        lenses.hide();
    }
};

$.offers.utils.page = function() {
    var currentPage = $('#pagination-bottom .current').text();

    return currentPage.length ? parseInt(currentPage) : 1;
};

$.offers.utils.checkedCategories = function() {
    return $.map($('#all-categories input[type="checkbox"]').
          filter(':checked'), function(element) { return element.id });
};

$.offers.utils.url = function(page) {
    var city = $.offers.utils.city(),
        checkedCategories = $.offers.utils.checkedCategories(),
        categories = [],
        url = '/' + city;

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

    if ( $( $.offers.sections.offers ).attr('data-time_period') ) {
        url += ( '&time_period=' + $( $.offers.sections.offers ).attr('data-time_period') );
    }

    if ( $( $.offers.sections.offers ).attr('data-search') ) {
        url += ( '&search=' + $( $.offers.sections.offers ).attr('data-search') );
    }

    return url;
};

$.offers.utils.renderOffers = function(offers) {
    var offerTemplate = $('div#offer-id'),
        temporaryContainer = $('<div class="hidden"></div>').appendTo( $('body') );

    $.each( offers, function() {
        console.log( this );
        var offer = offerTemplate.clone().
            attr('id', this['id']).
            attr('data-category', this.category_id);
        offer.find('a.offer-url').text( this.title );
        offer.find('a.offer-url').attr('href', this.provider_url);
        offer.find('img.offer-image').attr('src', this.image.thumb.url);
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
};

$.offers.utils.offersAheadCount = function(categoryIds) {
    var count = 0,
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
        }
    }

    return count;
};

$.offers.utils.changeCounterAndPaginate = function() {
    var totalSelectedOffersCount = $.offers.utils.selectedOffersCount();

    $.offers.utils.paginate( totalSelectedOffersCount );
    $('#offers-selected-count').text( totalSelectedOffersCount );
};

$.offers.utils.retrieveOffers = function(page) { // Retrieves offers, count and pagination
    $('div#loader').show();
    //$('#current-offers-count').append( $.api.loader() );
    $( $.offers.sections.offers ).removeAttr('data-search');

    $('.notification').hide();

    var checkedCategories = $.offers.utils.checkedCategories();
    if ( (checkedCategories.length > 0 && $.offers.utils.selectedOffersCount() > 0) || $( $.offers.sections.offers ).attr('data-search') ) {
        $.getJSON($.offers.utils.url(page), function(data) {
            $( $.offers.sections.offers ).html( data.offers );
            // $( $.offers.sections.offers ).html( $.offers.utils.renderOffers( $.parseJSON( data.offers ) ) );

            if ( page > 1 ) {
                $( $.offers.sections.pagination ).html( data.pagination );
                $( $.offers.sections.selectedCount ).html( data.count );
            } else {
                if ( $($.offers.sections.offers).attr('data-time_period') ) {
                    $( $.offers.sections.selectedCount ).html( data.count );
                    $.offers.utils.paginate( data.count );
                } else {
                    $.offers.utils.changeCounterAndPaginate();
                }
            }

            $.offers.utils.startCountDown();
            $.offers.utils.showFavourites();
            $.offers.utils.toggleOptions();
            $('div#loader').hide();
        });
    } else {
        //$('#current-offers-count').find('.loader').remove();
        $('#offers-section').find('.offer').remove();

        $.offers.utils.toggleOptions();
        $.offers.utils.changeCounterAndPaginate();
        $('div#loader').hide();
    }
};

$.offers.utils.getOffers = function(categoryIds) { // Retrieves just offers
    $('.notification').hide();
    $( $.offers.sections.offers ).removeAttr('data-search');

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
        var url = '/' + $.offers.utils.city() + '?categories=' + categoryIds.join(',');
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

            $.offers.utils.startCountDown();
            $('#current-offers-count').find('.loader').remove();
            $.offers.utils.paginate( totalSelectedOffersCount );
            $.offers.utils.showFavourites();
        });
    }

    $('#offers-selected-count').text( totalSelectedOffersCount );
};

$.offers.utils.selectedOffersCount = function() {
    var categories = $('#all-categories').find('input[type="checkbox"]').filter(':checked'),
        totalCount = 0;

    $.each( categories, function() {
        totalCount += parseInt( $(this).parent().next().text().replace(/\D/g, '') );
    });

    return totalCount;
};

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

};

// Bindings

var searchSubmitHandler = function() {
  var valueLength = $(this).find('#search').val().replace(/\s+/, '').length;

  if ( valueLength === 0 ) {
    return false;
  } else {
    $('#all-categories input[type="checkbox"]').prop('checked', false);
    $.each( $('#all-categories span.all-tags'), function() {
      var $this = $(this);

      $this.text( $this.data('original-text') );
    });

    $('#lenses').hide();
  }
};

var searchAjaxCompleteHandler = function(event, xhr, status) {
  var response = $.parseJSON( xhr.responseText );

  $( $.offers.sections.offers ).attr('data-search', true).
    html( response.offers );
  $('#offers-selected-count').text( response.total );
  $('#pagination-bottom').html( response.pagination );
  $.offers.utils.startCountDown();
  $('#no-results-found').hide();

  if ( parseInt(response.total) == 0 ) {
    $('#no-results-to-display').hide();
    $('#sort-buttons').hide();
    $('#no-results-for-time-period').hide();
    $('#no-results-found').show();
  }
};

var searchButtonClickHandler = function() {
  var form = $(this).parents('form'),
  input = form.find('#search');

  if ( input.val().replace(/\s+/, '').length > 0 ) {
    form.submit();
  }
};


var checkboxCategoryClickHandler = function() {
    var $this = $(this),
        checked = $this.prop('checked'),
        ul = $this.parents('ul'),
        tag = ul.prev().find('.all-tags'),
        checkboxes = ul.find('input[type="checkbox"]'),
        amount = parseInt( $this.parents('li').find('.amount').text() );

    if ( amount == 0 ) return false;

    $.offers.utils.rememberCategories();

    if ( checked ) {
        if ( checkboxes.length == checkboxes.filter(':checked').length ) {
            tag.data('original-text', tag.text()).
                text( tag.data('clear') );
        }
    } else {
        if ( tag.data('original-text') ) tag.text( tag.data('original-text') );
    }

    $.offers.utils.retrieveOffers(1);

};

var amountClickHandler = function() {
    $('#all-categories input[type="checkbox"]').prop('checked', false);

    var $this = $(this),
    categoryId = $this.prev().
        find('input[type="checkbox"]').
        prop('checked', true).
        attr('id');

    $.each( $('span.all-tags'), function() {
        var $this = $(this);

        $this.text( $this.data('original-text') );
    });

    $.offers.utils.showLenses();
    $.offers.utils.rememberCategories();
    $.offers.utils.retrieveOffers( 1 );
}

var allTagsClickHandler = function() {
    var $this = $(this),
    ul = $this.parent().next(),
    checkboxes = ul.find('input[type="checkbox"]'),
    check = true,
    amount = 0;

    $.map( checkboxes, function(e) {
        amount += parseInt( $(e).parents('li').find('.amount').text() );
    });

    if ( checkboxes.filter(':checked').length == checkboxes.length ) check = false;

    if ( check ) {
        $this.data('original-text', $this.text()).
            text( $this.data('clear') );
        $.offers.utils.showLenses();
    } else {
        $this.text( $this.data('original-text') );
    }

    checkboxes.prop('checked', check);
    $.offers.utils.rememberCategories();

    if ( amount == 0 ) return false;

    $.offers.utils.retrieveOffers(1);
}

var allOffersClickHandler = function(event) {
    event.preventDefault();
    event.stopPropagation();

    var checkboxes = $('div#filter').find('input[type="checkbox"]');
    if ( checkboxes.length != checkboxes.filter(':checked').length ) {
        checkboxes.prop('checked', true);

        $.each( $('span.all-tags'), function() {
            var $this = $(this);

            if ( ! $this.data('original-text') ) $this.data('original-text', $this.text());
            $this.text( $this.data('clear') );
        });

        $.offers.utils.setCookie('categories', 'all');

        $.offers.utils.retrieveOffers(1);
    }
}

var allOffersClearClickHandler = function(event) {
    event.preventDefault();
    event.stopPropagation();

    $('#offers-selected-count').text('0');

    $('div#filter').find('input[type="checkbox"]').prop('checked', false);

    $.each( $('span.all-tags'), function() {
        var $this = $(this);

        $this.text( $this.data('original-text') );
    });

    $( $.offers.sections.offers ).html('');
    $( $.offers.sections.pagination ).html('');
    $.offers.utils.toggleOptions();

    $.offers.utils.setCookie('categories', []);
}

$('document').ready(function() {

    // Refresh

    if ( document.body.id == 'offers-controller' ) {
        var refreshFilter = function() {
            $.getJSON('offers/refresh?city=' + $.offers.utils.city(), function(data) {
                if ( data.filter.length ) {
                    var newFilter = $(data.filter),
                        checkedCategories = $.offers.utils.checkedCategories(),
                        newFilterCheckboxes = newFilter.find('input[type="checkbox"]').
                            prop('checked', false).
                            bind('change', checkboxCategoryClickHandler),
                        newFilterTags = newFilter.find('#all-categories span.all-tags').bind('click', allTagsClickHandler);

                    $.each( newFilterCheckboxes, function() {
                        if ( checkedCategories.include( this.id ) ) this.checked = 'checked';
                    });

                    $.each( newFilterTags, function() {
                        var $this = $(this),
                            ul = $(this).parent().next(),
                            checkboxes = ul.find('input[type="checkbox"]');

                        if ( checkboxes.filter(':checked').length != checkboxes.length )
                            $this.text( $this.data('original-text') );
                    });

                    newFilter.find('#all-categories ul li span.amount').bind('click', amountClickHandler);
                    newFilter.find('#all-offers-check').bind('click', function(event) {
                        allOffersClickHandler(event);
                    });
                    newFilter.find('#all-offers-clear').bind('click', function(event) {
                        allOffersClearClickHandler(event);
                    });

                    newFilter.find('#search-button').
                      bind('click', searchButtonClickHandler);
                    newFilter.find('#search-form').
                      bind('submit', searchSubmitHandler).
                      bind('ajax:complete', searchAjaxCompleteHandler);
                }
            });
        }

        setInterval( refreshFilter, 30000 );
    }

    // cookies

    if ( $.cookie( $.offers.cookies_key ) && document.body.id == 'offers-controller' ) {
        $.offers.utils.copyCookies();

        var page = $.offers.cookies.page == 0 ? false : $.offers.cookies.page,
            categories = $.offers.cookies.categories.split(','),
            timePeriod = parseInt( $.offers.cookies.time_period ),
            sort = $.offers.cookies.sort.split(' ');


        $('#offers-selected-count').text(0);
        $('#offers-section div.offer').remove();
        $( $.offers.sections.pagination ).html('');


        $('#offers-section').attr('data-time_period', timePeriod).
            attr('data-sort-by', sort.join('|'));

        $('#all-categories input[type="checkbox"]').prop('checked', false);

        if ( categories.length == 1 && categories[0] == '' ) categories = [];

        if (  categories.length == 1 && categories[0] == 'all' ) {
            $('#all-categories input[type="checkbox"]').prop('checked', true);
        } else {
            $.each( categories, function(i,e) {
                $('input[type="checkbox"]#' + e).prop('checked', true);
            });
        }

        $.each( $('#all-categories span.all-tags'), function() {
            var $this = $(this),
                ul = $(this).parent().next(),
                checkboxes = ul.find('input[type="checkbox"]');

            if ( checkboxes.filter(':checked').length != checkboxes.length ) {
                $this.text( $this.data('original-text') );
            }
        });

        if ( $.offers.utils.selectedOffersCount() <= $.offers.offersPerPage ) {
            page = false;
            $.offers.utils.setCookie('page', false);
        }

        $('#all-offers').attr('data-page', page);

        if ( $('#sort-by-' + sort[0]).length ) {
            $('#sort-by-' + sort[0]).data('sort', sort[1]).
                addClass('current-sort').
                append( '<span class="' + sort[1] + '"></span>' );

            $.offers.latestSort = 'sort-by-' + sort[0];
        }

        $('#lenses li').removeClass('pressed');
        if ( timePeriod === 0 ) {
            $('#all-lens').addClass('pressed');
        } else if ( timePeriod == 1 ) {
            $('#today-lens').addClass('pressed');
        } else {
            $('#yesterday-lens').addClass('pressed');
        }

        $.offers.utils.retrieveOffers( parseInt(page) );

    }

    // cookies END

    $('div#pagination-bottom .pagination a').live('ajax:complete', function( event, xhr, status ) {
        var attributes = $.parseJSON( xhr.responseText );

        $('#offers-section').html( attributes.offers );
        $('#pagination-bottom').html( attributes.pagination );

        $("html:not(:animated)"+( ! $.browser.opera ? ",body:not(:animated)" : "")).animate({scrollTop: 25}, 500);
    });

    $('div#pagination-bottom .pagination a').live({
        click: function(event) {
            event.preventDefault();
            event.stopPropagation();

            var params = this.href.replace(/^.*\?/, '').split('&'),
                page = params[0].split('=')[1];

            $.offers.utils.setCookie('page', parseInt(page));

            $.offers.utils.retrieveOffers(page);
            $("html:not(:animated)"+( ! $.browser.opera ? ",body:not(:animated)" : "")).animate({scrollTop: 25}, 500);
        }
    });

    // Offer-bottom-more

    $("#offers-section .offer .offer-description-roll-up").live('click', function() {
        $(this).parents('.offer').find('.offer-details').toggle(300);
    });

    $("#offers-section .offer .offer-bottom").live('click', function() {
        $(this).parents('.offer').find('.offer-details').toggle(300);
    });
    // Categories

    $('#all-categories input[type="checkbox"]').
        bind('change', checkboxCategoryClickHandler);

    $('#all-categories ul li span.amount').bind('click', amountClickHandler);

    $('#all-offers-check').bind({
        hover: function() {
            $( '#all-categories' ).toggleClass('hover');
        },
        click: function(event) { allOffersClickHandler(event) }
    });

    $('#all-offers-clear').bind('click', function(event) {
        allOffersClearClickHandler(event);
    });

    $('#all-categories span.all-tags').bind({
        hover: function() {
            $(this).parent().next().toggleClass('hover');
        },
        click: allTagsClickHandler
    });

    // Sort

    if ( $('#sort-by-category_id').length && $('#offers-section').attr('data-sort-by') === undefined ) {
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
            $.offers.utils.setCookie('sort', sortBy + ' ' + direction);

            $.offers.latestSort = this.id;
            $this.append('<span class="' + $this.data('sort') + '"></span>');

            $.offers.utils.retrieveOffers(1);
        } else {
            $('#sort-buttons .notification').show();
        }
    });

    // Favourites

    if ( /\/offers\/favourites/.test(window.location.href) && $.cookie('favourites') ) {
        $.getJSON( '/offers/favourites?offers=' + $.cookie('favourites'), function(data) {
            var countContainer = $('#offers-selected-count');

            $( $.offers.sections.offers ).append( data.offers );

            countContainer.append( $.api.loader() );
            countContainer.text( data.count );
            countContainer.find('.loader').remove();

            $.offers.utils.showFavourites();
            $.offers.utils.startCountDown();

            $('div.offer div.add-button-added').unbind().bind('click', function(event) {
                var addedOffers = $.cookie('favourites').split(','),
                    offer = $(this).parents('div.offer'),
                    offerId = offer.attr('id').replace('offer-', ''),
                    index = addedOffers.indexOf(offerId),
                    currentCount = parseInt( countContainer.text() );

                if ( index != -1 ) {
                    addedOffers.splice(index, 1);
                    $.cookie( 'favourites', addedOffers.unique(), { expires: 7, path: '/' } );
                    offer.find('.add-button').removeClass('add-button-added');

                    offer.fadeOut();
                    countContainer.text( currentCount - 1 );
                }

                event.preventDefault();
                event.stopPropagation();
            });
        });
    }

    $.offers.utils.showFavourites();

    $('#offers-section div.offer div.add-button').live({
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

    $('html').click(function(event) {
        var citiesContainer = $('#all-cities'),
            target = $(event.target),
            targetId = target.attr('id');

        if ( target.parents('#all-cities').length === 0 && targetId != 'current-city' && targetId != 'all-cities' && citiesContainer.is(':visible') ) {
            citiesContainer.toggle();
        }
    });
// City selection 
    $('#current-city').click(function(event) {
        if ( event.target.id == 'current-city') $('#all-cities').toggle();
    });

    // Lenses

    $('#lenses li').click(function() {
        $('#lenses li').removeClass('pressed');
        $(this).addClass('pressed');

        var currentTimePeriod = parseInt($( $.offers.sections.offers ).attr('data-time_period')),
            timePeriod = 0;

        if ( !currentTimePeriod ) currentTimePeriod = 0;

        if ( this.id == 'today-lens' ) {
            timePeriod = 1;
        } else if ( this.id == 'yesterday-lens' ) {
            timePeriod = 2;
        }

        if ( currentTimePeriod != timePeriod ) {
            $( $.offers.sections.offers ).attr('data-time_period', timePeriod);
            $.offers.utils.setCookie('time_period', timePeriod);
            $.offers.utils.retrieveOffers( $.offers.utils.page() );
        }
    });

    $('#search-button').bind('click', searchButtonClickHandler);

    $('#search-form').
      bind('submit', searchSubmitHandler).
      bind('ajax:complete', searchAjaxCompleteHandler);

});
