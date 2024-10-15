NM.util = NM.util || {};

NM.util.openModal = function( ele ) {

    var dialogs = $(".modal");
    var currentId = ele.attr("id");

    var currentTop = 0;
    var currentLeft = 0;

    var n=1;

    for ( var dialog of dialogs ) {
        
        var $dialog = $(dialog)
        var modal = $dialog.find(".modal-dialog");

        if( currentId !=  $dialog.attr("id") ) {

            var top = modal.offset().top;
            var left = modal.offset().left;
    
            currentTop = 20*n;
            currentLeft = 20*n;

            n++

        }

    }

    ele.modal("show");

    ele.offset({ left: currentLeft, top: currentTop });

};
