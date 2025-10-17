AP.fontFamily = AP.fontFamily || {};

AP.fontFamily.fields = {
    listRoot: $( "#font-family-list-root" ),
    searchListForm: $( "#font-family-grid-search-form" ),
    detailRoot: $( "#font-family-detail-modal" ),
    detailForm: $( "#font-family-detail-form" ),
    detailSizesForm: $( "#font-family-size-grid-form" ),
    pictogramRoot: $( "#pictogram-modal" ),
    pictogramForm: $( "#pictogram-form" )
};

$( document ).ready( function() {
    if ( AP.fontFamily.fields.listRoot.length ) {
        AP.fontFamily.list.init();
    }
    if ( AP.fontFamily.fields.detailRoot.length ) {
        AP.fontFamily.detail.init();
		$( "#addSize i").after(" Aggiungi Dimensione");
    }
    if ( AP.fontFamily.fields.pictogramRoot.length ) {
        AP.fontFamily.pictogram.init();
    }
} );

AP.fontFamily.detail = ( function() {
	var pub = {};

	var defaultDetailForm = {
		data: {
			id: "",
			code: "",
            name: "",
			fontFamilySizes: new kendo.data.DataSource()
		},
		title: "Carica Font Family",
	};

	var viewModel = kendo.observable( {
		detailForm: defaultDetailForm,
		fontFamilySizes: new kendo.data.DataSource(),

		callback: {
			onCreate: undefined,
			onUpdate: undefined,
			onLoad: undefined,
		},

		resetForm: function() {
			var detailForm = AP.fontFamily.fields.detailForm;
			viewModel.get( 'fontFamilySizes' ).data( new kendo.data.DataSource() );

			var validator = detailForm.validate();
			validator.resetForm();

			detailForm.find( ".status" ).html( "" );

			viewModel.set( "detailForm", defaultDetailForm );
		},

		addSize: function( event ) {
			viewModel.get( "fontFamilySizes" ).add( { id: "", name: "" } );
		},

		removeSize: function( event ) {
			const name = event.data.name;
			const id = event.data.id;
			viewModel.get( "fontFamilySizes" ).remove( event.data );
			if (id && id != "") {
				NM.util.ajax( {
					method: "DELETE",
					url: "/manager/ajax/font-family-sizes",
					data: { 'fontFamilySizeId': id },
					callback: {
						done: function( xhr ) {
							if ( xhr.status == "SUCCESS" ) {
								AP.widget.notify(
									"success",
									"Dimensione " + name + " cancellata con successo",
								);
							}
						},
					},
				} );
			}
		},

		save: function( event ) {
			var detailForm = AP.fontFamily.fields.detailForm;
			var status = detailForm.find( ".status" );

			status.html(
				"<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
			);

			viewModel.set( "detailForm.data.fontFamilySize", viewModel.get( "fontFamilySizes" ).data() );

			if ( detailForm.valid() ) {
				NM.util.ajax( {
					method: "POST",
					url: "/manager/ajax/font-families",
					data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
					callback: {
						done: function( xhr ) {
							if ( xhr.status == "SUCCESS" ) {
								NM.util.autoHideMessage(
									status,
									"<span class='green'>Font Family salvata</span>",
								);

								setTimeout(
									() => $( "#font-family-detail-modal" ).modal( "hide" ),
									1000,
								);

								AP.util.fireCallback(
									"onSave",
									viewModel.get( "callback" ),
								);
							}
						},
					},
				} );
			}

			return false;
		},
	} );

	pub.new = function( { onSave } ) {
		if ( onSave ) {
			viewModel.set( "callback.onSave", onSave );
		}

		viewModel.resetForm();

		NM.util.openModal( AP.fontFamily.fields.detailRoot );
	};

	pub.edit = function( id, onSave ) {
		if ( onSave ) {
			viewModel.set( "callback.onSave", onSave );
		}

		NM.util.ajax( {
			method: "GET",
			url: "/manager/ajax/font-families/" + id,
			callback: {
				done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {

                        viewModel.set( "detailForm.data", xhr.data );
                        viewModel.set( "detailForm.title",  "Modifica Font Family < " + xhr.data.name + " >" );

                    }
				},
			},
		} );

		NM.util.ajax( {
			method: "GET",
			url: "/manager/ajax/font-family-sizes?fontFamilyId=" + id,
			callback: {
				done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {

                        viewModel.get( "fontFamilySizes" ).data( xhr.data );

                    }
				},
			},
		} );
        
		NM.util.openModal( AP.fontFamily.fields.detailRoot );
	};

	pub.editPictogram = function( id, onSave ) {
		if ( onSave ) {
			viewModel.set( "callback.onSave", onSave );
		}

		NM.util.ajax( {
			method: "GET",
			url: "/manager/ajax/pictograms?fontFamilyId=" + id,
			callback: {
				done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        viewModel.get( "pictograms" ).data( xhr.data )
                        NM.util.openModal( AP.fontFamily.fields.pictogramRoot );
                    }
				},
			},
		} );
	};

	pub.init = function() {
		kendo.bind( AP.fontFamily.fields.detailRoot, viewModel );

		var detailForm = AP.fontFamily.fields.detailForm;

		detailForm.validate( {
			onfocusout: function( element ) {
				$( element ).valid();
			},
			rules: {
				code: {
					required: true,
					checkCode: true,
					rangelength: [ 5, 5 ],
					remote: {
						url: "/manager/ajax/font-families/code-exists",
						data: {
							code: function() {
								return viewModel.get( "detailForm.data.code" );
							}
						},
						dataFilter: function( xhr ) {
							var json = JSON.parse( xhr );
							return json.data == false;
						},
					},
				},
			},
			messages: {
				code: {
					required: "Codice richiesto",
					rangelength: "Sono richiesti 5 caratteri",
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "Il codice esiste",
				},
			},
		} );
	};

	return pub;
} () );

AP.fontFamily.pictogram = ( function() {
	var pub = {};

	var defaultDetailForm = {
		data: {
			id: ""
		},
		title: "Carica Font Family",
	};

	var viewModel = kendo.observable( {
		detailForm: defaultDetailForm,
        pictograms: new kendo.data.DataSource(),
		callback: {
			onCreate: undefined,
			onUpdate: undefined,
			onLoad: undefined,
		},

		resetForm: function() {
			var detailForm = AP.fontFamily.fields.detailForm;

			var validator = detailForm.validate();
			validator.resetForm();

			detailForm.find( ".status" ).html( "" );

			viewModel.set( "detailForm", defaultDetailForm );
		},

		save: function( event ) {
			var detailForm = AP.fontFamily.fields.detailForm;
			var status = detailForm.find( ".status" );

			status.html(
				"<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
			);

			if ( detailForm.valid() ) {
				NM.util.ajax( {
					method: "POST",
					url: "/manager/ajax/font-families",
					data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
					callback: {
						done: function( xhr ) {
							if ( xhr.status == "SUCCESS" ) {
								NM.util.autoHideMessage(
									status,
									"<span class='green'>Linea salvata</span>",
								);

								setTimeout(
									() => $( "#line-detail-modal" ).modal( "hide" ),
									1000,
								);

								AP.util.fireCallback(
									"onSave",
									viewModel.get( "callback" ),
								);
							}
						},
					},
				} );
			}

			return false;
		},
	} );

	pub.new = function( { onSave } ) {
		if ( onSave ) {
			viewModel.set( "callback.onSave", onSave );
		}

		viewModel.resetForm();

		NM.util.openModal( AP.fontFamily.fields.detailRoot );
	};

	pub.edit = function( id, onSave ) {
		if ( onSave ) {
			viewModel.set( "callback.onSave", onSave );
		}

		viewModel.resetForm();

		NM.util.ajax( {
			method: "GET",
			url: "/manager/ajax/font-families/" + id,
			callback: {
				done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {

                        viewModel.set( "detailForm.data", xhr.data );
                        viewModel.set( "detailForm.title", "Modifica Font Family < " + xhr.data.name + " >" );

                        NM.util.openModal( AP.fontFamily.fields.detailRoot );
                    }
				},
			},
		} );
	};

	pub.init = function() {
		kendo.bind( AP.fontFamily.fields.detailRoot, viewModel );

		var detailForm = AP.fontFamily.fields.detailForm;

		detailForm.validate( {
			onfocusout: function( element ) {
				$( element ).valid();
			},
			rules: {
				code: {
					required: true,
					checkCode: true,
					rangelength: [ 5, 5 ],
					remote: {
						url: "/manager/ajax/pictograms/pictogram-exists",
						data: {
							id: function() {
								return viewModel.get( "detailForm.data.pic.id" );
							},
							fontFamily: function() {
								return viewModel.get( "detailForm.data.font.id" );
							},
						},
						dataFilter: function( xhr ) {
							var json = JSON.parse( xhr );
							return json.data == false;
						},
					},
				},
			},
			messages: {
				code: {
					required: "Codice richiesto",
					rangelength: "Sono richiesti 5 caratteri",
					checkCode: "Solo numeri, lettere, trattino o trattino basso",
					remote: "Il codice esiste",
				},
			},
		} );
	};

	return pub;
} () );

AP.fontFamily.list = ( function() {
    var pub = {};

    var detailApp = AP.fontFamily.detail;

    var dataSources = {
        items: NM.kendo.dataSource( { url: "/manager/ajax/font-families" } ),
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,

        search: function( event ) {
            var thisForm = AP.fontFamily.fields.searchListForm;

            var params = thisForm.serializeJSON();

            viewModel.rows.read( params );

            return false;
        },

        new: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.new( onSave );

            return false;
        },


        edit: function( event ) {
            var onSave = function() {
                viewModel.get( "rows" ).read();
            };

            detailApp.edit( event.data.id, onSave );

            return false;
        },

        delete: function( event ) {
            var checks = $( "#font-family-grid" ).find( "[name=selected]:checked" );

            if ( checks.length ) {
                var values = [];

                checks.each( function() {
                    values.push( $( this ).val() );
                } );

                var ids = values.toString();

                NM.util.ajax( {
                    method: "DELETE",
                    url: "/manager/ajax/font-families",
                    data: ids,
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.data.payload.hasOwnProperty( "errors" ) ) {
                                AP.widget.notify(
                                    "error",
                                    "Non riesco a cancellare tutti i valori",
                                );
                            } else {
                                AP.widget.notify(
                                    "success",
                                    "Cancellazione avvenuta con successo",
                                );
                            }
                            viewModel.rows.read();
                        },
                    },
                } );
            } else {
                AP.widget.notify( "warning", "Seleziona almeno un valore" );
            }
        }
    } );

    pub.init = function() {
        kendo.bind( AP.fontFamily.fields.listRoot, viewModel );
    };

    return pub;
} () );