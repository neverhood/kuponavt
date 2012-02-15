$(document).ready(function() {

	var neighbors = $.parseJSON( $('div#neighbors').text() );
	$('div#neighbors').remove();

	var api = $.api.offer = {
		// "CONSTANTS"
		LIMIT: 50, // Maximum number of before/after arrays elements
		GET_MORE_AT: 5, // Get more offers from server if either before or after array contains "value" elements
		NEIGHBORS_COUNT: 1, // Preload by "value" neighbors from both sides

		// variables
		id: parseInt($('.offer').attr('id').replace('offer-', '')),
		before: neighbors.before,
		after: neighbors.after,
		expectMore: true,
		directions: ['before', 'after'],
		neighbors: {
			before: [], after: []
		},
		loadingBefore: false,
		loadingAfter: false,

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
		preloadOffer: function(direction) {
			if ( direction == 'before' ) {
				if ( api.neighbors.before.length >= api.NEIGHBORS_COUNT ) api.neighbors.before.shift();
				api.loadingBefore = true;
				api.neighbors.before.push( api.getOffer( api.before.last() ) );
			} else if ( direction == 'after' ) {
				if ( api.neighbors.after.length >= api.NEIGHBORS_COUNT ) api.neighbors.after.pop();
				api.loadingAfter = true;
				api.neighbors.after.push( api.getOffer( api.after.first() ) );
			}
		},
		preloadOffers: function() {
			api.preloadOffer('before');
			api.preloadOffer('after');
		},
		refreshNeighbors: function() {
			$.getJSON( '/offers/' + api.id + '/neighbors', function( data ) {
				api.before = data.before;
				api.after = data.after;

				api.setExpectations();
				api.preloadOffers();
			});
		},
		getOffer: function(offerId) {
			var offer = {};

			$.getJSON('/offers/' + offerId, function(data) { offer.id = data.id, offer.html = data.offer });
			return offer;
		},
		next: function() {
			if ( api.after.length > 0 ) {
				if ( api.neighbors.before.length >= api.NEIGHBORS_COUNT ) api.neighbors.before.shift();
				api.neighbors.before.push( { id: api.id, html: $('#offers-section').html() } );
				api.before.push( api.id );

				var nextOfferId = api.id = api.after.shift();
				api.preloadOffer('after');
				api.getOffer( nextOfferId );

				if ( api.directions.include('after') && api.timeToLoadMore() ) api.refreshNeighbors();
			} else { alert('no'); }
		},
		prev: function() {
			if ( api.before.length > 0 ) {
				if ( api.neighbors.after.length >= api.NEIGHBORS_COUNT ) api.neighbors.after.pop(); // Delete the last cached offer
				api.neighbors.after.unshift( { id: api.id, html: $('#offers-section').html() } );
				api.after.unshift( api.id );

				var prevOffer = api.id = api.before.pop();
				api.preloadOffer('before');
				api.getOffer( prevOffer );

				if ( api.directions.include('before') && api.timeToLoadMore() ) api.refreshNeighbors();
			} else { alert('no'); }
		}
	};

	api.setExpectations();
	api.preloadOffers();


});