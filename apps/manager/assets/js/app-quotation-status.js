AP.namespace( "quotation" );

Object.assign( AP.quotation.fields, {
    statusModalRoot: $( "#qt-status-modal-root" ),
    statusForm: $( "#qt-status-detail-form" ),
    changeFileModal: $( "#qt-status-file-root" ),
    changeFileForm: $( "#qt-status-file-form" ),
} );

$( document ).ready( function() {
    if ( AP.quotation.fields.statusModalRoot.length ) {
        AP.quotation.status.init();
    }
} );


AP.quotation.status = ( function() {
    var pub = {};
    var fields = AP.quotation.fields;

    var loadHistory = function() {

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

    var setFileChange = function( event, field ) {

        const file = event.target.files[0];

        if ( file ) {
            const reader = new FileReader();
            reader.readAsDataURL( file );
            reader.onload = function( evt ) {
                const base64 = evt.target.result;
                viewModel.set( field, base64 );
            };

        }

    };

    var init = function() {

        kendo.bind( fields.statusModalRoot, viewModel );

        viewModel.set( "statuses", AP.page.statuses );

    };

    var viewModel = kendo.observable( {
        fileForm: {
            data: {
                quotation: {
                    id: AP.page.quotation.id
                },
                statusHistory: {
                    id: "",
                    file: {
                        currentId: "",
                        newFileBase64: "",
                    }
                },
            },
            title: ""
        },
        detailForm: {
            data: {
                id: "",
                quotation: {
                    id: AP.page.quotation.id
                },
                statusHistory: {
                    id: "",
                    status: {
                        id: ""
                    }
                },
                newStatus: {
                    id: "",
                },
                statusFile: {
                    id: "",
                    base64: ""
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

        onFileChange: function( event ) {

            setFileChange( event, "detailForm.data.statusFile.base64" );

        },

        onFileRowChange: function( event ) {

            setFileChange( event, "fileForm.data.statusHistory.file.newFileBase64" );

        },

        editFile: function( event ) {

            console.log( "editFile:event", event );

            viewModel.set( "fileForm.title", "Modifica il documento per lo stato < " + event.data.id + " >" );

            viewModel.set( "fileForm.data.statusHistory.id", event.data.id );
            viewModel.set( "fileForm.data.statusHistory.file.currentId", event.data.file.id );

            NM.util.openModal( fields.changeFileModal, null, true );

        },

        showDocumentRequired: function( event ) {

            const statusId = viewModel.get( "detailForm.data.newStatus.id" );

            if ( statusId == "CCN" ) {
                return true;
            }
            return false;

        },

        getCreatedAt: function( event ) {
            return NM.kendo.formatISODate( event.createdAt );
        },

        download: function( event ) {

            var uri = event.data?.file?.uri;
            if ( !uri ) { return; }

            window.open( uri, "_blank" ).focus();

        },

        saveFile: function( event ) {
            var thisForm = fields.changeFileForm;

            console.log( "thisForm", thisForm );

            thisForm.validate( {
                onfocusout: function( element ) {
                    $( element ).valid();
                },
                rules: {
                    statusFile: {
                        required: true
                    },
                },
                messages: {
                    statusFile: {
                        required: "Carica il documento"
                    }
                }
            } );


            if ( thisForm.valid() ) {

                var data = viewModel.get( "fileForm.data" );
                var status = thisForm.find( ".status" );
                var statusId = viewModel.get( "fileForm.data.statusHistory.id" );

                console.log( "statusId", statusId );

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/statuses/" + statusId + "/files",
                    data: JSON.stringify( data ),
                    callback: {
                        done: function( xhr ) {

                            status.html( "" );

                            AP.widget.notify( "success", "File salvato correttamente." );

                            // setTimeout(function () { window.location.reload() }, 1000);

                        }
                    }
                } );
            }

            return false;
        },

        save: function( event ) {
            var thisForm = fields.statusForm;

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
                        required: "Carica il documento di conferma del cliente"
                    }

                }
            } );

            if ( thisForm.valid() ) {

                var data = viewModel.get( "detailForm.data" );
                var status = thisForm.find( ".status" );

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/quotations/" + AP.page.quotation.id + "/statuses",
                    data: JSON.stringify( data ),
                    callback: {
                        done: function( xhr ) {

                            status.html( "" );

                            AP.widget.notify( "success", "Stato salvato correttamente." );

                            setTimeout( function() {
                                window.location.reload();
                            }, 1000 );

                        }
                    }
                } );
            }

            return false;
        },

    } );

    pub.edit = function() {
        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/" + AP.page.quotation.id,
            callback: {
                done: function( xhr ) {
                    viewModel.set( "detailForm.data.statusHistory", xhr.data.statusHistory );

                    // Trova lo stato successivo nell'array
                    var currentStatusId = viewModel.get( "detailForm.data.statusHistory.status.id" );

                    var currentIndex = AP.page.statuses.findIndex( function( status ) {
                        return status.id === currentStatusId;
                    } );

                    var nextStatus = "";
                    if ( currentIndex !== -1 && currentIndex < AP.page.statuses.length - 1 ) {
                        nextStatus = AP.page.statuses[currentIndex + 1];
                    }

                    viewModel.set( "detailForm.data.newStatus", nextStatus );

                }
            }
        } );

        loadHistory();

        NM.util.openModal( fields.statusModalRoot );

        $( "#qt-status-nav-detail-but" ).trigger( "click" );
    };

    pub.init = function() {

        init();

    };

    return pub;
} () );