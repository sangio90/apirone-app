AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    statusModalRoot: $( "#qt-status-modal-root" ),
    statusForm: $( "#qt-status-detail-form" ),
} );

AP.quotation.status = ( function() {
    var pub = {};
    var fields = AP.quotation.fields;

    var loadStatusHistory = function() {

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/statuses",
            callback: {
                done: function( xhr ) {
                    const data = xhr.data;
                    const parsedData = [];

                    viewModel.set( "rows", xhr.data );

                }
            }
        } );

    };

    var init = function() {

        kendo.bind( fields.statusModalRoot, viewModel );

        AP.page.statuses.unshift( { id: "", name: "-- Seleziona uno stato" } );

        viewModel.set( "statuses", AP.page.statuses );

        $( "#statusFile" ).on( "change", function( event ) {

            const file = event.target.files[0];

            if ( file ) {
                const reader = new FileReader();
                reader.readAsDataURL( file );
                reader.onload = function( evt ) {
                    const base64 = evt.target.result;
                    viewModel.set( "detailForm.data.statusFile", { "file": base64, "id": null } );
                };

            }
        } );

    };


    var viewModel = kendo.observable( {
        detailForm: {
            data: {
                id: "",
                statusHistory: {
                    id: "",
                    status: {
                        id: ""
                    }
                },
                newStatus: {
                    id: "",
                }
            }
        },

        rows: new kendo.data.DataSource(),

        statuses: AP.page.statuses,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        showDocumentRequired: function( event ) {

            const statusId = viewModel.get( "detailForm.data.newStatus.status.id" );
            console.log( "documentRequired", statusId );

            if ( statusId == "CCN" ) {
                return true;
            }
            return false;

        },

        toggleDownloadDocumentButton: function() {
            const statusFileId = viewModel.get( "detailForm.data.statusFile.id" );
            if ( !statusFileId ) {
                return false;
            }
            return true;

        },

        download: function( event ) {
            var uri = event.data?.fileUri;
            if ( !uri ) { return; }

            var link = document.createElement( "a" );
            link.href = uri;
            link.download = viewModel.detailForm.data.statusFile.name || "document.pdf";
            document.body.appendChild( link );
            link.click();
            document.body.removeChild( link );
        },

        downloadFile: function() {
            var uri = viewModel.detailForm.data.statusFile.uri;
            if ( !uri ) { return; }

            var link = document.createElement( "a" );
            link.href = uri;
            link.download = viewModel.detailForm.data.statusFile.name || "document.pdf";
            document.body.appendChild( link );
            link.click();
            document.body.removeChild( link );
        },


        delete: function( event ) {

            event.stopPropagation();
            var itemId = event.currentTarget.dataset.id;

            bootbox.confirm( {
                title: "Conferma eliminazione",
                message: "Sei sicuro di voler cancellare questa riga del preventivo?",
                buttons: {
                    confirm: {
                        label: "Si, confermo",
                        className: "btn-primary",
                    },
                    cancel: {
                        label: "No, chiudi",
                        className: "btn-danger",
                    },
                },
                callback: function( result ) {
                    if ( result ) {
                        NM.util.ajax( {
                            method: "DELETE",
                            url: "/manager/ajax/quotation-items",
                            data: itemId,
                            callback: {
                                done: function( xhr ) {
                                    if ( xhr.status == "INVALID" ) {
                                        NM.form.showMessages( xhr.data );
                                        return;
                                    }

                                    AP.widget.notify( "success", "Stato cancellato correttamente." );
                                    window.location.href = "/manager/quotations/" + AP.page.quotation.id + "/statuses";
                                }
                            }
                        } );
                    }
                },
            } );

            return false;
        },

        save: function( event ) {
            var thisForm = fields.statusForm;

            console.log( "save", thisForm );

            thisForm.validate( {
                onfocusout: function( element ) {
                    $( element ).valid();
                },
                rules: {
                    newStatus: {
                        required: true
                    },
                    statusFile: {
                        required: function() {

                            var statusId = viewModel.get( "detailForm.data.newStatus.id" );

                            if ( statusId == "CCN" ) {
                                return true;
                            }
                            return false;
                        }
                    },
                },

                messages: {
                    newStatus: {
                        required: "Stato richiesto.",
                    },
                    statusFile: {
                        required: "Carica il documento del cliente"
                    }

                }
            } );

            if ( thisForm.valid() ) {

                const data = viewModel.get( "detailForm.data" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/statuses",
                    data: JSON.stringify( data ),
                    callback: {
                        done: function( xhr ) {
                            AP.widget.notify( "success", "Stato salvato correttamente." );
                            viewModel.set( "detailForm", {} );

                            loadStatuses();

                        }
                    }
                } );
            }

            return false;
        },

    } );

    pub.edit = function() {

        init();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/" + AP.page.quotation.id,
            callback: {
                done: function( xhr ) {
                    viewModel.set( "detailForm.data.statusHistory", xhr.data.statusHistory );
                }
            }
        } );

        loadStatusHistory();

        // kendo.bind( fields.statusModalRoot, viewModel );

        NM.util.openModal( fields.statusModalRoot );

    };

    return pub;
} () );