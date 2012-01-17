// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$('document').ready(function() {

    if ( document.body.id == 'admin-bot-controller' ) {

        $.admin = {};

        $.admin.updateOffer = function(entryId) {
            $.ajax({
                type: 'DELETE',
                url: '/admin/bot/' + entryId,
                success: function(data) {
                    if ( data.status == 'success' ) {
                        $('#entry-' + entryId).fadeOut();
                    }
                }
            });
        };

        $('.buy-button').click(function(e) {
            $.admin.updateOffer( $(this).parents('.offer').attr('id').replace('entry-', '') );
            return false;
            e.preventDefault();
            e.stopPropagation();
        });

    }
});
