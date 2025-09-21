AP.widget = AP.widget || {};

AP.widget.notify = function( type, message, title ) {
    var stack_bar_top = { dir1: "down", dir2: "right", push: "top", spacing1: 0, spacing2: 0 };

    var icon = "";
    var finalTitle = title;

    switch ( type ) {
    case "error":
        icon = "fas fa-exclamation-circle";
        finalTitle = title ? title : "Errore";
        break;

    case "info":
        icon = "fas fa-info-circle";
        finalTitle = title ? title : "Info";
        break;

    case "warning":
        icon = "fas fa-exclamation-triangle";
        finalTitle = title ? title : "Attenzione";
        break;

    case "success":
        icon = "fas fa-check-circle";
        finalTitle = title ? title : "Completato";
        break;

    default:
        throw "Notify type [ " + type + " ] not found";
        return;
    }

    var notice = new PNotify( {
        delay: 3000,
        type: type,
        title: finalTitle,
        text: message,
        addclass: "stack-bar-top",
        width: "100%",
        icon: icon,
        buttons: {
            closer: true,
            sticker: false,
        },
        stack: stack_bar_top,
    } );

    notice.get().click( function() {
        notice.remove();
    } );
};

AP.widget.autoClearMessage = function( id, message ) {
    var ele = $( "#" + id );

    ele.html( message );

    setTimeout( () => ele.html( "" ), 2000 );
};
