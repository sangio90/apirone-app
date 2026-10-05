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

/*
    ESC chiude la modale aperta.

    Bootstrap lo fa da sé solo se la modale prende il focus, cioè se ha tabindex="-1":
    la maggior parte delle modali del manager non lo ha, il focus resta sulla pagina e
    l'ESC non arriva mai alla modale. Invece di toccare ogni vista, qui un gestore unico:
    - chiude solo la modale aperta per ultima ( pila aggiornata da shown/hidden ), così
      con due modali sovrapposte si chiude quella sopra;
    - non interviene quando Bootstrap gestisce già l'ESC ( modale con tabindex e focus
      dentro: es. le conferme bootbox, che hanno una loro logica sull'ESC );
    - rispetta keyboard: false / data-bs-keyboard="false";
    - lascia l'ESC ai popup Kendo aperti ( tendine, calendari ): prima si chiude quello;
    - usa hide() di Bootstrap, quindi gli handler su hide.bs.modal valgono come sempre.
*/
( function() {
    var openModals = [];

    $( document )
        .on( "shown.bs.modal", ".modal", function() {
            openModals = openModals.filter( function( el ) { return el !== this; }, this );
            openModals.push( this );
        } )
        .on( "hidden.bs.modal", ".modal", function() {
            openModals = openModals.filter( function( el ) { return el !== this; }, this );
        } )
        .on( "keydown.apModalEsc", function( e ) {
            if ( e.key !== "Escape" || e.isDefaultPrevented() ) { return; }

            // popup Kendo aperto: l'ESC è suo
            if ( $( ".k-animation-container:visible" ).length ) { return; }

            var top = null;
            for ( var i = openModals.length - 1; i >= 0; i-- ) {
                if ( $( openModals[ i ] ).hasClass( "show" ) ) { top = openModals[ i ]; break; }
            }
            if ( !top || typeof bootstrap === "undefined" ) { return; }

            // con tabindex e focus dentro la modale ci pensa già Bootstrap
            if ( top.hasAttribute( "tabindex" ) && top.contains( e.target ) ) { return; }

            var modal = bootstrap.Modal.getInstance( top );
            if ( !modal || ( modal._config && modal._config.keyboard === false ) ) { return; }

            modal.hide();
        } );
}() );

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

// Come AP.hasRole, ma per whitelist di email (feature riservate a utenti specifici,
// es. pulsanti di debug JSON visibili solo a chi sta sviluppando quella funzionalità).
AP.hasEmail = function (emails) {
    const userEmail = AP.config.user?.email;
    if (!userEmail) return false;

    let emailsArray = [];
    if (Array.isArray(emails)) {
        emailsArray = emails;
    } else if (typeof emails === "string") {
        emailsArray = emails.split('/').map(e => e.trim());
    }

    return emailsArray.includes(userEmail);
};

kendo.data.binders.email = kendo.data.Binder.extend({
    refresh: function() {
        var emailsString = this.element.getAttribute("data-email-list");
        var hasPermission = AP.hasEmail(emailsString);

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