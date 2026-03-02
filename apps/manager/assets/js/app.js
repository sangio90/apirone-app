AP.core = AP.core || {};

$( document ).ready( function() {

    /* dom inits */

    if ( $( "#sidebar-left" ).length ) {
        AP.core.init();
    }

    /* message */

    if ( AP.message ) {
        if ( Object.keys( AP.message ).length != 0 ) {
            AP.widget.notify( AP.message.type, AP.message.message );
        }
    }

    renderCostsToggle();

} );

AP.core = ( function() {

    var pub = {};

    pub.init = function() { };

    pub.setSidebar = function() { };

    return pub;

}() );

AP.hasRole = function (roles) {
    const userRole = AP.config.user?.role;
    if (!userRole) return false;

    let rolesArray = [];
    if (Array.isArray(roles)) {
        rolesArray = roles;
    } else if (typeof roles === "string") {
        rolesArray = roles.split('/').map(r => r.trim());
    }

    return rolesArray.includes(userRole);
};

kendo.data.binders.role = kendo.data.Binder.extend({
    refresh: function() {
        var rolesString = this.element.getAttribute("data-role-list");
        var hasPermission = AP.hasRole(rolesString);

        if (hasPermission) {
            $(this.element).show();
        } else {
            $(this.element).hide();
        }
    }
});

kendo.data.binders.roleEnable = kendo.data.Binder.extend({
    refresh: function() {
        var rolesString = this.element.getAttribute("data-role-list");
        var hasPermission = AP.hasRole(rolesString);

        var widget = kendo.widgetInstance($(this.element));        
        if (widget && typeof widget.enable === "function") {
            widget.enable(hasPermission);
        } else {
            $(this.element).prop("disabled", !hasPermission);
        }
    }
});

AP.namespace = function( name ) {
    var parts = name.split( "." );
    var current = AP;

    for ( var i = 0; i < parts.length; i++ ) {
        if ( !current[parts[i]] ) {
            current[parts[i]] = {};
        }
        current = current[parts[i]];
    }

    current.fields = current.fields || {};

    return current;
};

/*
    for user pref
*/

AP.setUserPref = function( key, value ) {

    var user = AP.config.user.shortId;
    NM.storage.set( "apirOne:" + user + ":" + key, value );
};

AP.getUserPref = function( key, defaultValue ) {

    var user = AP.config.user.shortId;
    return NM.storage.get( "apirOne:" + user + ":" + key, defaultValue );
};

AP.deleteUserPref = function( key ) {
    var user = AP.config.user.shortId;
    NM.storage.delete( "apirOne:" + user + ":" + key );
};

AP.loading = {
    show: function() {
        $( "#global-loading-spinner" ).css( "display", "flex" );
    },
    hide: function() {
        $( "#global-loading-spinner" ).css( "display", "none" );
    }
};

AP.toggleCosts = function() {
    var current = AP.getUserPref("showCosts");
    var next = !current;

    AP.setUserPref("showCosts", next);

    document.dispatchEvent(new CustomEvent("costsToggled", {
        detail: { showCosts: next }
    }));
};

function renderCostsToggle() {
  if (!AP.hasRole('ADM/TCD/CMA')) {
    AP.setUserPref("showCosts", false);
    return;
  }
  const li = document.getElementById("costs-toggle");
  if (!li) return;

  const showCosts = AP.getUserPref("showCosts") == undefined ? false : AP.getUserPref("showCosts");
  AP.setUserPref("showCosts", showCosts);

  li.innerHTML = `
    <a role="menuitem" tabindex="-1" href="javascript:void(0)" id="toggle-costs-link">
      <i class="bx ${showCosts == false ? "bx-show" : "bx-hide"}"></i>
      ${showCosts == false ? "Mostra costi" : "Nascondi costi"}
    </a>
  `;

  li.querySelector("#toggle-costs-link").addEventListener("click", () => {
    AP.toggleCosts();
    renderCostsToggle();
  });
}