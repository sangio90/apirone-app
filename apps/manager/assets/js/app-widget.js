AP.widget = AP.widget || {};

AP.widget.notify = function( type, message, title ) {

    console.log("ZB.widget.notify")

	var stack_topleft = {"dir1": "down", "dir2": "right", "push": "top"};
	var stack_bottomleft = {"dir1": "right", "dir2": "up", "push": "top"};
	var stack_bottomright = {"dir1": "up", "dir2": "left", "firstpos1": 15, "firstpos2": 15};
	var stack_bar_top = {"dir1": "down", "dir2": "right", "push": "top", "spacing1": 0, "spacing2": 0};
	var stack_bar_bottom = {"dir1": "up", "dir2": "right", "push": "bottom", "spacing1": 0, "spacing2": 0};

    var icon = '';

    switch ( type ) {
        case "error":
            icon = "fas fa-exclamation-circle";
            title = title ? title : "Errore";
            break;

        case "info":
            icon = "fas fa-info-circle";
            title = title ? title : "Informazioni";
            break;

        case "warning":
            icon = "fas fa-exclamation-triangle";
            title = title ? title : "Attenzione";
            break;

        case "success":
            icon = "fas fa-check-circle";
            title = title ? title : "Ok";
            break;

        default:
            throw 'Notify type [ ' + type + ' ] not found';
            return;
      }
      
    var notice = new PNotify({
        type: type,
        title: title,
        text: message,
        addclass: 'stack-bar-top',
        width: "100%",
        icon: icon,
        buttons: {
            closer: true,
            sticker: false
        },
        stack: stack_bar_top
    });

    notice.get().click(function() {
        notice.remove();
    });

}
