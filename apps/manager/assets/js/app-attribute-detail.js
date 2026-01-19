AP.attribute = AP.attribute || {};
AP.fields.attribute = AP.fields.attribute || {};

AP.fields.attribute.detail = {
    detailRoot: $( "#attribute-detail-modal" ),
    detailForm: $( "#attribute-detail-form" ),
    valueForm : $( "#attribute-values-add-form" ),
    valuesForm: $( "#attribute-values-form" )
};

$( document ).ready( function(){

    if ( AP.fields.attribute.detail.detailRoot.length ) {

        AP.attribute.detail.init();

    }

} );

/*
	detail
*/

AP.attribute.detail = ( function() {

    var pub = {};

    var fields = AP.fields.attribute.detail;

    var componentApp = AP.component.modal;
    var fileApp = AP.file.modal;

    var defaults = {

        detailForm: {
            data: {
                status: {
                    id: "ACT"
                },
                id: "",
                code: "",
                orderBy: 0,
                categories: [],
                selectedCategories: [],
                nameItem: {
                    id: "",
                    name: "",
                    lang: {
                        id: "IT"
                    }
                },
            },
            title: "Carica attributo",
            action: "create"
        },

        suggestForm: {
            data: {
                id: "",
                name: "",
                code: "",
                allowNote: false,
                affectToImage: false
            }
        },

        valueForm: {
            data: {
                allowNote: false,
                affectToImage: false,
                status: {
                    id: "ACT"
                },
                id: "",
                orderBy: 0,
                nameItem: {
                    id: "",
                    name: "",
                    lang: {
                        id: "IT"
                    }
                }
            },

            labelButton: "Carica"
        },

    };

    var viewModel = kendo.observable( {

        detailForm: defaults.detailForm,
        valueForm: defaults.valueForm,
        suggestForm: defaults.suggestForm,

        categories: AP.page.categories,
        statusList: AP.page.attributeStatusList,

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined
        },

        getFormValueTitle: function() {

            var data = viewModel.get( "valueForm.data" );
            var values = viewModel.get( "detailForm.data.values" );

            if ( data.id ) {

                return "Modifica valore < " + data.id + " >";

            }

            if ( values?.total() == 0 ) {

                return "Carica il primo valore";

            }

            return "Carica valore";


        },


        isUpdate: function() {
            return viewModel.get( "detailForm.data.id" ).length;
        },

        openImagesList: function( event ) {

            console.log( "openImagesList", event );

            var value = {
                type: "attributeValue",
                id: event.data.id,
                name: event.data.rawValue.name,
            };

            fileApp.open( value );

            return false;
        },

        openComponentsList: function( event ) {

            var attr = viewModel.get( "detailForm.data" );
            var rawValue = event.data.rawValue;
            var attributeValueId = event.data.id;

            var value = {
                type: "attributeValue",
                attributeValue: {
                    id: attributeValueId,
                },
                attribute: {
                    id: attr.id,
                    name: attr.name,
                },
                rawValue: {
                    id: rawValue.id,
                    name: rawValue.name,
                },
            };

            componentApp.open( value );

            return false;
        },

        resetDetailForm: function() {

            var thisForm = fields.detailForm;

            viewModel.set( "detailForm", defaults.detailForm );

            thisForm.find( ".status" ).html( "" );
            thisForm.data( "validator" ).resetForm();

            $( "#attribute-nav-values-but" ).removeClass( "disabled" );

        },

        isValuesGridVisible: function() {

            var values = viewModel.get( "detailForm.data.values" );

            if ( values?.total() ) {
                return true;
            }

            return false;

        },

        deleteValues: function( event ) {

            var status = $( "#attribute-values-delete-status" );
            var checks = $( "#attribute-values-form" ).find( "[name=selected]:checked" );

            if ( checks.length ) {

                var values = [];
                checks.each( function(){
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();
                var id = viewModel.get( "detailForm.data.id" );

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/attributes/" + id + "/raw-values",
                    data: ids,
                    callback: {
                        done: function( xhr ) {

                            if( xhr.data.payload.hasOwnProperty( "errors" ) ) {

                                AP.widget.notify( "error", "Non riesco a cancellare tutti i valori" );

                            } else {

                                AP.widget.notify( "success", "Cancellazione avvenuta con successo" );

                            }

                            loadAttribute( id );

                        }
                    }
                } );

            } else {

                NM.util.autoHideMessage( status, "<span class='red'>Seleziona almeno un valore</span>" );

            }

        },

        updateValues: function( event ) {

            // var ids = values.toString();

            var values = viewModel.get( "detailForm.data.values" );
            var id = viewModel.get( "detailForm.data.id" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/attributes/" + id + "/raw-values",
                data: JSON.stringify( values ),
                callback: {
                    done: function( xhr ) {

                        AP.widget.notify( "success", "Aggiornamento avvenuto con successo" );

                        loadAttribute( id );

                    }
                }
            } );

        },


        editValue: function( event ) {

            viewModel.set( "valueForm.data", event.data );
            viewModel.set( "valueForm.title", "Modifica valore < " + event.data.id + " >" );
            viewModel.set( "valueForm.labelButton", "Aggiorna" );

        },

        save: function() {

            var detailRoot = fields.detailRoot;
            var status = detailRoot.find( ".status.errors-counter" );

            var thisForm = fields.detailForm;

            if( thisForm.valid() ) {

                var data = viewModel.get( "detailForm.data" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/attributes",
                    data: JSON.stringify( data ),
                    callback: {
                        done: function( xhr ) {

                            // NM.util.autoHideMessage( status, "<span class='green'>" + xhr.data.message.text + "</span>" );

                            setTimeout( () => {

                                if ( !viewModel.isUpdate() ) {

                                    var tab = $( "#attribute-nav-values-but" );

                                    tab.removeClass( "disabled" );
                                    tab.tab( "show" );

                                    loadAttribute( xhr.data.payload.id );

                                }

                                var callback = viewModel.isUpdate() ? "onUpdate" : "onCreate";
                                AP.util.fireCallback( callback, viewModel.get( "callback" ) );

                            }, 700 );

                        }
                    }
                } );

            }

            return false;

        },

        newValue: function() {

            viewModel.resetValueForm();

        },

        saveValue: function() {

            var thisForm = fields.valueForm;
            var status = $( "#attribute-values-add-form-status" );

            var attrId = viewModel.get( "detailForm.data.id" );

            if( thisForm.valid() ) {

                status.html( "<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>" );

                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/attributes/values",
                    data: JSON.stringify( {
                        value: viewModel.get( "valueForm.data" ),
                        attributeId: attrId
                    } ),
                    callback: {
                        done: function( xhr ) {

                            NM.util.autoHideMessage( status, "<span class='green'>Valore salvato</span>" );

                            var id = viewModel.get( "detailForm.data.id" );

                            loadAttribute( { id: id } );

                            AP.util.fireCallback( "onUpdateValue", viewModel.get( "callback" ) );

                        }
                    }
                } );

            }

            return false;

        },

    } );

    var loadAttribute = function( id ) {

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/attributes/" + id,
            callback: {
                done: function( xhr ) {

                    var selectedCategories = [];

                    if( xhr.data?.categories ) {
                        for ( var category of xhr.data.categories )  {
                            selectedCategories.push( category );
                        }
                    }

                    var valuesDataSource = new kendo.data.DataSource( {
                        data: xhr.data.values,
                        sort: { field: "orderBy", dir: "asc" }
                    } );

                    delete xhr.data.values;

                    viewModel.set( "detailForm.data", xhr.data );
                    viewModel.set( "detailForm.data.selectedCategories", selectedCategories );
                    viewModel.set( "detailForm.data.values", valuesDataSource );
                    viewModel.set( "detailForm.title", "Modifica attributo <" + xhr.data.name + " >" );
                    // viewModel.set("detailForm.labelButton", "Aggiorna");

                    /*
						load suggest for values
					*/

                    AP.util.fireCallback( "onLoad", viewModel.get( "callback" ) );

                    NM.util.openModal( $( "#attribute-detail-modal" ) );

                    var table = $( "#attribute-values-grid .k-grid-container .k-table" );

                    initSuggest();

                    table.kendoSortable( {
                        axis: "y",
                        filter: ">tbody >tr",
                        hint: function( element ) {
                            var ele = $( "<div>" );
                            var text = $( element ).find( "td.sortable" ).text();

                            ele.text( text )
                                .height( element.height() )
                                .width( element.width() )
                                .addClass( "sortable-hint" );

                            return ele;

                        },
                        placeholder: function( element ) {
                            return element.clone()
                                .addClass( "sortable-placeholder" )
                                .height( element.height() )
                                .width( element.width() );
                        },

                        end: function( event ) {

                            if( event.newIndex != event.oldIndex ) {

                                var values = viewModel.get( "detailForm.data.values" ).data();
                                var thisForm = $( "#attribute-values-form" );
                                var status = thisForm.find( ".status" );

                                console.log( "values", values.length );

                                // INFO: kendo send an extra item to remove accordingly to direction of d&d
                                if ( event.oldIndex < event.newIndex ) {
                                    var removeItem = event.oldIndex;
                                } else {
                                    var removeItem = event.oldIndex+1;
                                }

                                status.html( "<img src='/assets/main/img/ajax-loading.svg' width=20 height=20>" );

                                var count = 1;

                                table.find( "tr" ).each( function( index ) {

                                    if ( index != removeItem ) {

                                        var ele = $( this );
                                        var uid = ele.data( "uid" );

                                        for( var value of values ) {

                                            if ( value.get( "uid" ) == uid ) {

                                                value.set( "orderBy", count*10 );
                                            }
                                        }

                                        count++;

                                    }

                                } );

                                NM.util.ajax( {
                                    method: "POST",
                                    url: "/manager/ajax/attributes/" + id + "/raw-values/sort",
                                    data: JSON.stringify( viewModel.get( "detailForm.data.values" ).data() ),
                                    callback: {
                                        done: function( xhr ) {
                                            NM.util.autoHideMessage( status, "<span class='green'>Ordinamento salvato.</span>" );
                                        }
                                    }
                                } );

                            }
                        }

                    } );
                }
            }
        } );

    };

    var initSuggest = function() {

        var suggest = $( "#attribute-suggest-raw-values" );
        var autocomplete = suggest.data( "kendoAutoComplete" );
        var suggestTemplate = $( "#raw-value-suggest-row-tmpl" ).html();

        if ( autocomplete ) {
            return;
        }

        suggest.keypress( function( event ){
            if( event.keyCode == 13 ){
                return false;
            }
        } );

        suggest.kendoAutoComplete( {
            dataTextField: "name",
            highlightFirst: true,
            minLength: 2,
            dataSource: new kendo.data.DataSource( {
                serverFiltering: true,
                transport: {
                    read: {
                        url: "/manager/ajax/attributes/raw-values",
                        data: {
                            str: function() {
                                return suggest.data( "kendoAutoComplete" ).value();
                            },
                        },
                    },
                    parameterMap : function( data, type ) {
                        if ( type === "read" ) {
                            return { "str": data.str() };
                        }
                    }
                },
                schema: {
                    data: function( xhr ) {
                        return xhr.data;
                    }
                },
            } ),
            select: function( event ) {
                var dataItem = this.dataItem( event.item.index() );

                // TODO: add check if value already exists
                var exists = false;

                if( !exists ) {

                    NM.util.ajax( {
                        method: "POST",
                        url: "/manager/ajax/attributes/" + viewModel.get( "detailForm.data.id" ) + "/raw-values/add",
                        data: JSON.stringify( { id: dataItem.id } ),
                        callback: {
                            done: function( xhr ) {
                                AP.widget.notify( "success", "Valore aggiunto con successo" );

                                suggest.data( "kendoAutoComplete" ).value( "" );

                                setTimeout( () => {

                                    loadAttribute( viewModel.get( "detailForm.data.id" ) );

                                    var callback = viewModel.isUpdate() ? "onUpdate" : "onCreate";
                                    AP.util.fireCallback( callback, viewModel.get( "callback" ) );

                                }, 700 );

                            }
                        }
                    } );

                }
            },
            template: kendo.template( suggestTemplate ),
            noDataTemplate: "<div>NESSUN RECORD</div>"
        } );

    };

    pub.new = function( onCreate ) {

        if( onCreate ) {
            viewModel.set( "callback.onCreate", onCreate );
        }

        viewModel.resetDetailForm();

        NM.util.openModal( $( "#attribute-detail-modal" ) );

        return;

    };

    pub.edit = function( id, onUpdate ) {

        if( onUpdate ) {
            viewModel.set( "callback.onUpdate", onUpdate );
        }

        viewModel.resetDetailForm();

        loadAttribute( id );

    };

    pub.init = function() {

        kendo.bind( fields.detailRoot, viewModel );

        // var valueForm = fields.valueForm;
        var detailForm = fields.detailForm;

        detailForm.validate( {
            onfocusout: function( element ) {
                $( element ).valid();
            },
            rules: {
                attr: {
                    required: true
                },
                code: {
                    checkCode: true,
                    required: true,
                    maxlength: 5,
                    remote: {
                        url: "/manager/ajax/attributes/code-exists",
                        data: { id: function() { return  viewModel.get( "detailForm.data.id" ); } },
                        dataFilter: function( xhr ) {
                            var json = JSON.parse( xhr );
                            return json.data == false;
                        }
                    }
                },
            },
            messages: {
                attr: {
                    required: "Descrizione principale richiesta",
                },
                code: {
                    required: "Codice richiesto",
                    checkCode: "Solo numeri, lettere, trattino o trattino basso",
                    remote: "Il codice esiste",
                    max: "Al massimo 5 caratteri"
                },
            },

        } );

    };

    return pub;

}() );
