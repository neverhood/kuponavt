$(document).ready(function() {

	var neighbors = $.parseJSON( $('div#neighbors').text() );
	$('div#neighbors').remove();

	var api = $.api.offer = {
		// "CONSTANTS"
		LIMIT: 50, // Maximum number of before/after arrays elements
		GET_MORE_AT: 5, // Get more offers from server if either before or after array contains "value" elements
		NEIGHBORS_COUNT: 3, // Preload by "value" neighbors from both sides
		MIN_PRELOADED_OFFERS: 2,

		// variables
		id: parseInt($('#offer-plus-arrows div.offer').attr('id').replace('offer-', '')),
		html: $('#offer-plus-arrows').html(),
		before: neighbors.before,
		after: neighbors.after,
		expectMore: true,
		directions: ['before', 'after'],
		neighbors: { before: [], after: [] },
		loading: false,
        preloading: false,

		// Functions
		shouldExpectMore: function() {
			return ( api.before.length == api.LIMIT || api.after.length == api.LIMIT );
		},
		possibleDirections: function() {
			var directions = [];
			if ( api.after.length == api.LIMIT ) directions.push( 'after' );
			if ( api.before.length == api.LIMIT ) directions.push( 'before' );

			return directions;
		},
		setExpectations: function() {
			api.expectMore = api.shouldExpectMore();
			api.directions = api.possibleDirections();
		},

		timeToLoadMore: function() {
			if ( api.directions.length == 0 ) return false;
			var index = 0;

			while ( index < api.directions.length ) {
				if ( api[ api.directions[index] ].length <= api.GET_MORE_AT ) return true;
				index++;
			}

			return false;
		},
		refreshNeighbors: function() {
            api.loading = true;
			$.getJSON( '/offers/' + api.id + '/neighbors', function( data ) {
				api.before = data.before;
				api.after = data.after;

				api.setExpectations();
                api.loading = false;

                $('#loader').remove();
                $('#left, #right').show();
			});
		},
		getOffers: function(offerId) {
			var offer = {};

            //if ( $('#loader').length == 0 ) $('#loader-container').append('<img src="/assets/loader.gif" id="loader" />');
            //$('#left, #right').hide();

			$.getJSON('/offers/' + offerId, function(data) { 
				offer.id = data.id, offer.html = data.offer;
				if ( typeof data.before != 'undefined' ) api.neighbors.before = data.before;
				if ( typeof data.after != 'undefined' ) api.neighbors.after = data.after;

                $('#loader').remove();
                $('#left, #right').show();
                api.preloading = false;
			});

			return offer;
		},
		show: function(direction) {
			if ( direction != 'after' && direction != 'before' ) return;

			if ( api[direction].length && !api.loading && $('#loader').length == 0 ) {
				var inverseDirection = direction == 'after' ? 'before' : 'after',
					currentOffer = { id: api.id, html: api.html },
					offerId = direction == 'after' ? api.after.first() : api.before.last(),
					offerIndex = direction == 'after' ? 0 : (api.neighbors.before.length - 1);

				if ( api.neighbors[direction].length && api.neighbors[direction][offerIndex].id == offerId ) {
					var offer = direction == 'after' ? api.neighbors.after.first() : api.neighbors.before.last();

					// ready to move
					if ( api[inverseDirection].length >= api.LIMIT )
						inverseDirection == 'after' ? api.neighbors.after.pop() : api.neighbors.before.shift();

					// store current offer
					direction == 'after' ? api.neighbors.before.push( currentOffer ) :
												 api.neighbors.after.unshift( currentOffer );

					// store current offer id to inverseDirection and set a new offer
					if ( direction == 'after' ) {
						api.after.shift() && api.neighbors.after.shift();
						api.before.push( api.id );
					} else {
						api.before.pop() && api.neighbors.before.pop();
						api.after.unshift( api.id );
					}
					api.id = offer.id; api.html = offer.html;
					$('#offer-plus-arrows').html( api.html );

					if ( api[direction].length > api.neighbors[direction].length && api.neighbors[direction].length <= api.MIN_PRELOADED_OFFERS ) {
						api.getOffers( api.id );
					}
					if ( api.directions.include(direction) && api.timeToLoadMore() ) api.refreshNeighbors();
					api.toggleArrows();
				} else {
                    if ( $('#loader').length == 0 ) $('#loader-container').append('<img src="/assets/loader.gif" id="loader" />');
					$('#left, #right').hide();
                    api.preloading = true;
					return;
				}
			}
		},
		toggleArrows: function() {
			if ( api.before.length == 0 && api.neighbors.before.length == 0 ) {
				$('#left').hide();
			} else { $('#left').show(); }

			if ( api.after.length == 0 && api.neighbors.after.length == 0 ) {
				$('#right').hide();
			} else { $('#right').show(); }

			$.each( $('#offer-plus-arrows div.offer p.time-left, #offer-plus-arrows div.offer p.time-left-red'), function() {
			    $this = $(this);

			    if ( $this.data('countdown') === undefined && $this.is(':visible') ) $this.countdown( new Date($this.text().trim()), { prefix: '', finish: 'Завершено' } );
			});
		}
	};

	api.setExpectations();
	$.api.offer.html = $('#offer-plus-arrows').html();
	api.toggleArrows();
	
	var beforeOffers = $('#before div.offer'),
		afterOffers = $('#after div.offer');

	if ( beforeOffers.length ) {
		$.each( beforeOffers, function() {
			var offer = $(this);
			api.neighbors.before.push( {html: offer.wrap('<div>').parent().html(), id: this.id.replace('offer-', '')} );
		});
	}
	if ( afterOffers.length ) {
		$.each( afterOffers, function() {
			var offer = $(this);
			api.neighbors.after.push( {html: offer.wrap('<div>').parent().html(), id: this.id.replace('offer-', '')} );
		});
	}
	// if ( $('#before div.offer').length > 1 ) api.neighbors.before = $.parseJSON( $('#before').html() );
	// if ( $('#after div.offer').length > 1 ) api.neighbors.after = $.parseJSON( $('#after').html() );

	$(document).keydown(function(event) {
		var code = event.keyCode || event.which;

		if ( code == 37 ) $.api.offer.show('before');
		if ( code == 39 ) $.api.offer.show('after');
	});

	$('#right').live('click', function() {
		$.api.offer.show('after');
	});

	$('#left').live('click', function() {
		$.api.offer.show('before');
	});

});
