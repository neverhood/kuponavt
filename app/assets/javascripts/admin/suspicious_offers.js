// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$('#admin-suspicious_offers-controller').ready(function() {

    if ( $('#admin-suspicious_offers-controller').length ) {
        $.admin = {
            input: $('#filter')
        }

        $.admin.updateOffer = function(offerId, attribute, newValue) {
            $.ajax({
                type: 'PUT',
                url: '/admin/suspicious_offers/' + offerId + '?' + attribute + '=' + newValue,
                success: function(data) {
                    if ( data.status == 'success' ) {
                        $('#offer-' + offerId).find('.offer-left-side').append('<div style="color:red; font-weight:bold">UPDATED</div>');

                        if ( attribute == 'category_id' ) {
                            $.admin.input.find('input[type="checkbox"]').filter(':checked').prop('checked', false);
                        } else {
                            $.admin.input.val('');
                        }
                    }
                }
            });
        }

        if ( /ends_at/.test( window.location.href ) ) {
            $.admin.input= $('#ends_at');
        } else if ( /provided_id/.test( window.location.href ) ) {
            $.admin.input= $('#provided_id');
        }

        $.admin.inputContainer = $.admin.input.parent();
        $.admin.offerIdInput = $('#offer_id');

        $.admin.input.find('input[type="checkbox"]').unbind();

        $('.offer').hover(
            function() {
                var $this = $(this),
                    top = $this.offset().top,
                    left = $this.offset().left,
                    topModifier = 0;

                if ( $.admin.input.attr('id') == 'filter' ) {
                    topModifier = -100;
                }

                $.admin.inputContainer.
                    show().
                    css({
                    position: 'absolute',
                    top: top + topModifier,
                    left: (left + $this.width() + 50)
                });

                $('#offer_id').val( this.id.replace('offer-', ''));
            },

            function() {
                $.admin.input.find('input[type="checkbox"]').filter(':checked').prop('checked', false);
            }
        );

        $.admin.input.find('input[type="checkbox"]').bind('click', function() {
            var offerId = $.admin.offerIdInput.val(),
            categoryId = this.id;

            $.admin.updateOffer(offerId, 'category_id', categoryId);
        });

        $('#ends_at, #provided_id').unbind().keydown(function(event) {
            var code = (event.keyCode ? event.keyCode : event.which),
                attribute = this.id,
                newValue = this.value,
                offerId = $('#offer_id').val();

            if ( code == 13 ) {
                $.admin.updateOffer(offerId, attribute, newValue);
            }
        });
    }

});
