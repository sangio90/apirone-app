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

// Spinner globale. show/hide lo gestiscono a mano i chiamanti; begin/end li usa
// NM.util.ajax per le richieste di salvataggio ( contatore delle richieste in
// corso ). Lo spinner resta visibile finché c'è l'uno o l'altro: un hide()
// non nasconde un salvataggio ancora in corso e viceversa.
AP.loading = ( function() {
    var manual  = false;
    var pending = 0;
    var timer   = null;
    // le richieste veloci non fanno lampeggiare lo spinner
    var DELAY = 150;

    var render = function() {
        var $spinner = $( "#global-loading-spinner" );
        if ( manual ) {
            clearTimeout( timer );
            timer = null;
            $spinner.css( "display", "flex" );
        } else if ( pending > 0 ) {
            if ( !timer && $spinner.css( "display" ) == "none" ) {
                timer = setTimeout( function() {
                    timer = null;
                    if ( manual || pending > 0 ) {
                        $spinner.css( "display", "flex" );
                    }
                }, DELAY );
            }
        } else {
            clearTimeout( timer );
            timer = null;
            $spinner.css( "display", "none" );
        }
    };

    return {
        show: function() {
            manual = true;
            render();
        },
        hide: function() {
            manual = false;
            render();
        },
        begin: function() {
            pending++;
            render();
        },
        end: function() {
            pending = Math.max( 0, pending - 1 );
            render();
        }
    };
} () );

// Elementi di catalogo ( prodotti, attributi, valori ) che non si possono
// eliminare perché usati in preventivi in corso ( CatalogUsageService ): elenca
// i preventivi con i link alle righe da togliere.
AP.showCatalogInUse = function( data ) {
    var quotations = data.quotations || [];
    var combinations = Number( data.combinations ) || 0;
    var html = quotations.length
        ? "<p>Impossibile eliminare: gli elementi selezionati (o i loro figli) sono in uso in preventivi in corso. Toglili dai preventivi e riprova.</p>"
        : "<p>Impossibile eliminare: gli elementi selezionati (o i loro figli) sono in uso.</p>";

    if ( quotations.length ) {
        html += "<p class='mb-1'>Usati " + ( quotations.length == 1 ? "nel preventivo" : "nei preventivi" ) + ":</p><ul>";

        // Tipo categoria -> ?tab= gestito da AP.quotation.detail.checkUrlTab
        var tabByType = { PLA: "plate", SEG: "signage", ACC: "accessory", ART: "article" };
        var labelByType = { PLA: "Placca", SEG: "Segnaletica", ACC: "Accessorio", ART: "Articolo" };

        quotations.forEach( function( q ) {
            var url = "/manager/quotations/" + encodeURIComponent( q.id );
            var label = "n. " + kendo.htmlEncode( q.number ) + ( q.version !== "" && q.version != null ? " (rev. " + kendo.htmlEncode( q.version ) + ")" : "" );

            html += "<li><a href='" + url + "' target='_blank'>" + label + "</a>";

            if ( q.items && q.items.length ) {
                html += "<ul>";

                q.items.forEach( function( item ) {
                    var params = new URLSearchParams();

                    if ( tabByType[ item.type ] ) params.set( "tab", tabByType[ item.type ] );
                    if ( item.zoneId ) params.set( "zone", item.zoneId );
                    if ( item.itemIds && item.itemIds.length ) params.set( "highlight", item.itemIds.join( "," ) );

                    var itemLabel = kendo.htmlEncode( item.zoneName || "Zona senza nome" )
                        + " – " + ( labelByType[ item.type ] || "Riga" )
                        + ( item.count > 1 ? " (" + item.count + " righe)" : "" );

                    html += "<li><a href='" + url + "?" + params.toString() + "' target='_blank'>" + itemLabel + "</a></li>";
                } );

                html += "</ul>";
            }

            html += "</li>";
        } );

        html += "</ul>";
    }

    if ( combinations ) {
        html += "<p>Usati in " + combinations + ( combinations == 1 ? " combinazione" : " combinazioni" ) + " del prodotto.</p>";
    }

    bootbox.alert( { title: "Elementi in uso", message: html } );
};

// Elenco di elementi non più a catalogo ( CatalogUsageService ) per gli avvisi
// su revisione, duplica e modifica di righe di preventivo.
AP.notInCatalogMessage = function( labels, conclusion ) {
    var html = "<p>Questi elementi non sono più a catalogo:</p><ul>";
    labels.forEach( function( label ) {
        html += "<li>" + kendo.htmlEncode( label ) + "</li>";
    } );
    html += "</ul>";
    if ( conclusion ) {
        html += "<p>" + conclusion + "</p>";
    }
    return html;
};

// Elementi non più a catalogo nelle righe di un preventivo: revisione e duplica
// non copiano quelle righe, l'avviso va dato prima di confermare.
AP.loadNotInCatalog = function( quotationId, callback ) {
    NM.util.ajax( {
        method: "GET",
        url: "/manager/ajax/quotations/" + quotationId + "/not-in-catalog",
        callback: {
            done: function( xhr ) {
                callback( ( xhr && xhr.data && xhr.data.labels ) || [] );
            }
        }
    } );
};

// Riga di preventivo riaperta in modifica che usa elementi non più a catalogo:
// resta valida così com'è, ma quegli elementi, una volta cambiati, non si
// possono più scegliere.
AP.warnNotInCatalog = function( quotationItemId ) {
    if ( !quotationItemId ) {
        return;
    }
    NM.util.ajax( {
        method: "GET",
        url: "/manager/ajax/quotation-items/" + quotationItemId + "/not-in-catalog",
        callback: {
            done: function( xhr ) {
                var labels = ( xhr && xhr.data && xhr.data.labels ) || [];
                if ( labels.length ) {
                    // notifica, non una modale: la riga si apre già in una modale
                    AP.widget.notify(
                        "warning",
                        "Non più a catalogo: " + labels.join( ", " ) + ". La riga resta valida così com'è, ma se li cambi non potrai più sceglierli.",
                        "Elementi non più a catalogo"
                    );
                }
            }
        }
    } );
};

// Albero attributi / valori di un prodotto per i configuratori dei preventivi.
// Il server esclude gli elementi eliminati dal catalogo, tranne quelli già
// scelti nella riga di preventivo in modifica ( quotationItemId ).
AP.productItemsUrl = function( productId, originId, quotationItemId ) {
    var url = "/manager/ajax/product-items?productId=" + productId;
    if ( originId ) {
        url += "&originId=" + originId;
    }
    if ( quotationItemId ) {
        url += "&quotationItemId=" + quotationItemId;
    }
    return url;
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