$(document).ready(function() {

	var neighbors = $.parseJSON( $('div#neighbors').text() );
	$('div#neighbors').remove();

	var api = $.api.offer = {
		// "CONSTANTS"
		LIMIT: 50, // Maximum number of before/after arrays elements
		GET_MORE_AT: 5, // Get more offers from server if either before or after array contains "value" elements

		// variables
		id: parseInt($('.offer').attr('id').replace('offer-', '')),
		before: neighbors.before,
		after: neighbors.after,
		expectMore: true,
		directions: ['before', 'after'],
		neighbors: {
			prev: [], next: []
		},

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
		preloadOffers: function() {
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
			api.id = offerId;

			$.getJSON('/offers/' + offerId, function(data) {

			});
		},
		next: function() {
			if ( api.after.length > 0 ) {
				api.before.push( api.id );
				api.getOffer( api.after.shift() );

				if ( api.directions.include('after') && api.timeToLoadMore() ) api.refreshNeighbors();
			}
		},
		prev: function() {
			if ( api.before.length > 0 ) {
				api.after.unshift( api.id );
				api.getOffer( api.before.pop() );

				if ( api.directions.include('before') && api.timeToLoadMore() ) api.refreshNeighbors();
			}
		}
	};

	api.setExpectations();
	api.preloadOffers();


});