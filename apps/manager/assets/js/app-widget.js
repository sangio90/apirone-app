AP.widget = AP.widget || {};

AP.widget.notify = function (type, message, title) {

	var stack_bar_top = {"dir1": "down", "dir2": "right", "push": "top", "spacing1": 0, "spacing2": 0};

    var icon = "";
    var title = "";

    switch (type) {
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
            throw "Notify type [ " + type + " ] not found";
            return;
      }

    var notice = new PNotify({
        delay   : 3000,
        type    : type,
        title   : title,
        text    : message,
        addclass: "stack-bar-top",
        width   : "100%",
        icon    : icon,
        buttons : {
            closer : true,
            sticker: false
        },
        stack: stack_bar_top
    });

    notice.get().click(function () {
        notice.remove();
    });

};


AP.widget.autoClearMessage = function (id, message) {

    var ele = $( "#" + id );

    ele.html( message );

    setTimeout(() => ele.html(""), 2000);

};
