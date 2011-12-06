// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$('document').ready(function() {

    $.admin = {
        filter: $('#filter')
    };

    $.admin.filterContainer = $.admin.filter.parent();
    $.admin.offerIdInput = $.admin.filter.find('#offer_id');

    $.admin.filter.find('input[type="checkbox"]').unbind();

    $('.offer').hover(
        function() {
            var $this = $(this),
                top = $this.offset().top,
                left = $this.offset().left;

            $.admin.filterContainer.
                show().
                css({
                    position: 'absolute',
                    top: top - 100,
                    left: (left + $this.width() + 50)
                }).
                find('#offer_id').val( this.id.replace('offer-', ''));
        },

        function() {
            $.admin.filter.find('input[type="checkbox"]').filter(':checked').prop('checked', false);
        }
    );

    $.admin.filter.find('input[type="checkbox"]').bind('click', function() {
        var offerId = $.admin.offerIdInput.val(),
        categoryId = this.id;

        $.ajax({
            type: 'PUT',
            url: '/admin/suspicious_offers/' + offerId + '?category_id=' + categoryId,
            success: function(data) {
                if ( data.status == 'success' ) {
                    $('#offer-' + offerId).find('.offer-left-side').append('<div style="color:red; font-weight:bold">UPDATED</div>');

                    $.admin.filter.find('input[type="checkbox"]').filter(':checked').prop('checked', false);
                }
            }
        });

    });

});
