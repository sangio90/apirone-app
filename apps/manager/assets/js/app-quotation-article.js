AP.namespace( "article" );

Object.assign( AP.quotation.fields, {
    articleModalRoot: $( "#article-modal-root" ),
} );

$( document ).ready( function() {
    if ( AP.quotation.fields.articleModalRoot.length ) {
        AP.article.modal.init();
    }
} );

AP.article.modal = ( function() {

    var pub = {};
    var fields = AP.quotation.fields;

    var defaultDetailForm = {
        data: {
            id: "",
            quotationItem: {
                id: "",
                name: "",
                quantity: 1,
                note: "",
                price: {
                    total: 0,
                    amount: 0,
                },
                quotationZone: {
                    id: ""
                },
                article: {
                    code: "",
                    id: ""
                },
                status: {
                    id: "ACT",
                    name: "Attivo"
                }
            },
        },
        articles: [],
        title: "Carica servizio",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        //preimpostiamo il prezzo con quello definito nell'anagrafica servizi
        setDefault: function( event ) {
            const article = viewModel.get('articles').find(article => article.id == $(event.currentTarget).val())
            if (article && article.price && article.price.amount > 0) {
                viewModel.set('detailForm.data.quotationItem.price.amount', article.price.amount)
            }
            if (article && article.descriptionItem && article.descriptionItem.name != '') {
                viewModel.set('detailForm.data.quotationItem.note', article.descriptionItem.name)
            }
        },

        save: function( event ) {
            let data = viewModel.get('detailForm.data');

            data.id = AP.page.quotation.id;
            data.quotationItem.price.amount = parseFloat(data.quotationItem.price.amount)
            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/quotation-items/article",
                data: JSON.stringify( data ),
                callback: {
                    done: function( xhr ) {
                        $( "#signage-modal" ).hide();
                        AP.widget.notify( "success", "Segnaletica salvata nel preventivo." );
                        viewModel.set( "detailForm", defaultDetailForm );

                        setTimeout( function() {
                            window.location.reload();
                        }, 1000 );
                    },
                }
            } );

            return false;
        },

        normalizeDecimal: function (event) {
            const el = event.currentTarget;
            let v = el.value || "";

            v = v.replace(/,/g, ".");

            v = v.replace(/[^0-9.]/g, "");

            const firstDot = v.indexOf(".");
            if (firstDot !== -1) {
                v =
                v.slice(0, firstDot + 1) +
                v.slice(firstDot + 1).replace(/\./g, "");
            }

            el.value = v;

            viewModel.set('detailForm.data.quotationItem.price.amount', v);
        },

        resetForm: function() {
            viewModel.set( "detailForm", defaultDetailForm );
        },
    } );

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        viewModel.set( "detailForm.data.quotationItem.quotationZone", AP.quotation.detail.config().zone );

        NM.util.openModal( fields.articleModalRoot );

    };

    pub.edit = function( id, onSave ) {
        viewModel.resetForm();
        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotation-items/article/" + id,
            callback: {
                done: function( xhr ) {
                    xhr.data.quotationItem.price.amount = xhr.data.quotationItem.price.total
                    viewModel.set( "detailForm.data.quotationItem", xhr.data.quotationItem );
                    NM.util.openModal( fields.articleModalRoot );
                },
            },
        } );

        renderQuotationItemTotals( id );
        AP.loading.hide();
    };

    pub.init = function() {
        kendo.bind( fields.articleModalRoot, viewModel );

        AP.loading.show();
        
        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/articles/",
            callback: {
                done: function( xhr ) {
                    if( xhr.status == "INVALID" ) {
                        AP.loading.hide();
                        NM.form.showMessages( xhr.data );
                        return;
                    }

                    if ( xhr.data.success == false ) {
                        AP.widget.notify( "error", xhr.data.error ? xhr.data.error : "Errore durante la lettura dei servizi." );
                        AP.loading.hide();
                        return;
                    }
                    if (xhr.data && xhr.data.length > 0) {
                        xhr.data.forEach( function (article) {
                            article.label = article.code +  " (" + article.name + ")"
                        })
                        viewModel.set( "articles", xhr.data );
                    }
                    AP.loading.hide();
                }
            }
        } );
    };

    renderQuotationItemTotals = function( quotationItemId ) {
        NM.util.ajax( {
            method: "GET",
            url: `/manager/ajax/quotation-items/${quotationItemId}/total`,
            callback: {
                done: function( xhr ) {
                    if( xhr.data ) {
                        if ( !xhr.data.id || xhr.data.id != quotationItemId ) {
                            $( "#quotation-totals-item" ).hide();
                        } else {
                            viewModel.set( "detailForm.data.totals", xhr.data );
                            var totals = viewModel.get( "detailForm.data.totals" );
                            if ( xhr.data ) {
                                const table = $( "#quotation-totals-item" ).find( "table" )[0];
                                totals.products.forEach( function( row ) {
                                    $( table ).append( `
                                        <tr>
                                            <td>${row.id} - ${row.label}</td>
                                            <td>${row.amount.toLocaleString( "it-IT", { style: "currency", currency: "EUR" } )}</td>
                                        </tr>
                                    ` );
                                } );
                                $( table ).append(
                                    `<tr>
                                        <td>${totals.quantity.label}</td>
                                        <td>${totals.quantity.count}</td>
                                    </tr>
                                    <tr style="font-weight: bold">
                                        <td>${totals.total.label}</td>
                                        <td>${totals.total.amount.toLocaleString( "it-IT", { style: "currency", currency: "EUR" } )}</td>
                                    </tr>
                                    `
                                );
                            }
                            $( "#quotation-totals-item" ).show();
                        }
                    }
                }
            }
        } );
    };

    return pub;
} () );
