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

		callback: {
			onCreate: undefined,
			onUpdate: undefined,
			onLoad: undefined,
		},

		resetForm: function() {
			var detailForm = AP.fontFamily.fields.detailForm;
			// viewModel.get( 'fontFamilySizes' ).data( new kendo.data.DataSource() );

			NM.form.clearMessages( $("#font-family-size-grid-form") );

			detailForm.find( ".status" ).html( "" );

			viewModel.set( "detailForm", defaultDetailForm );
		},

		addSize: function( event ) {
			viewModel.get( "detailForm.data.fontFamilySizes" ).add( { id: "", name: "" } );
		},

		removeSize: function( event ) {
			const name = event.data.name;
			const id = event.data.id;
			viewModel.get( "detailForm.data.fontFamilySizes" ).remove( event.data );
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
		viewModel.resetForm();
		
		if ( onSave ) {
			viewModel.set( "callback.onSave", onSave );
		}

		NM.util.ajax( {
			method: "GET",
			url: "/manager/ajax/font-families/" + id,
			callback: {
				done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {

                        viewModel.set( "detailForm.data.id", xhr.data.id );
                        viewModel.set( "detailForm.data.code", xhr.data.code );
                        viewModel.set( "detailForm.data.name", xhr.data.name );
                        viewModel.set( "detailForm.title",  "Modifica Font Family < " + xhr.data.name + " >" );

                    }
				},
			},
		} );

		NM.util.ajax( {
			method: "GET",
			url: `/manager/ajax/font-family/${id}/sizes`,
			callback: {
				done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        viewModel.get( "detailForm.data.fontFamilySizes" ).data( xhr.data );
                    }
				},
			},
		} );
        
		NM.util.openModal( AP.fontFamily.fields.detailRoot );
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
							id: function() {
								return viewModel.get( "detailForm.data.id" );
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
			id: "",
			name: "",
			fontFamilyPictograms: new kendo.data.DataSource(),
			pictogram: {
				id: "",
				name: "",
				image: null
			}
		},
		title: "Pittogrammi",
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
			var detailForm = AP.fontFamily.fields.pictogramForm;

			var validator = detailForm.validate();
			validator.resetForm();

			detailForm.find( ".status" ).html( "" );
			$('#pictogramFileUpload').val('')

			viewModel.set( "detailForm", defaultDetailForm );
		},

		setDescription: function( event) {
			$( '#pictogramDescription' ).text(viewModel.get('detailForm.data.pictogram.name'))
			viewModel.checkCanSave()
		},

		checkCanSave: function( event ) {
			return viewModel.get('detailForm.data.pictogram.id') == '' || viewModel.get('detailForm.data.pictogram.image') == null
		},

		remove: function( event ) {
			const name = event.data.name;
			const id = event.data.id;
			NM.util.ajax( {
				method: "DELETE",
				url: "/manager/ajax/pictograms",
				data: { 'pictogramId': id },
				callback: {
					done: function( xhr ) {
						if ( xhr.status == "SUCCESS" ) {
							AP.widget.notify(
								"success",
								"Pittogramma " + name + " cancellato con successo",
							);

							AP.util.fireCallback(
								NM.util.ajax( {
									method: "GET",
									url: `/manager/ajax/font-family/${viewModel.get('detailForm.data.id')}/pictograms`,
									callback: {
										done: function( xhr ) {
											if ( xhr.status == "SUCCESS" ) {
												viewModel.set( "detailForm.data.pictogram", {
													id: "",
													name: "",
													image: null
												} )
												viewModel.set( "detailForm.data.fontFamilyPictograms", xhr.data );
												var pictograms = AP.page.pictogramCodes
												const filtered = pictograms.filter(function(p) {
													return !xhr.data.some(s => s.code === p.id)
												});
												viewModel.set('pictograms', filtered)
												NM.util.openModal( AP.fontFamily.fields.pictogramRoot );

											}
										},
									},
								} )
							);
						}
					},
				},
			} );
		},

		save: function( event ) {
			var detailForm = AP.fontFamily.fields.pictogramForm;
			var status = detailForm.find( ".status" );

			status.html(
				"<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
			);

			if ( detailForm.valid() ) {
				NM.util.ajax( {
					method: "POST",
					url: "/manager/ajax/pictograms",
					data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
					callback: {
						done: function( xhr ) {
							if ( xhr.status == "SUCCESS" ) {
								NM.util.autoHideMessage(
									status,
									"<span class='green'>Pittogramma salvato</span>",
								);

								AP.util.fireCallback(
									NM.util.ajax( {
										method: "GET",
										url: `/manager/ajax/font-family/${viewModel.get('detailForm.data.id')}/pictograms`,
										callback: {
											done: function( xhr ) {
												if ( xhr.status == "SUCCESS" ) {
													viewModel.set( "detailForm.data.pictogram", {
														id: "",
														name: "",
														image: null
													} )
													viewModel.set( "detailForm.data.fontFamilyPictograms", xhr.data );
													var pictograms = viewModel.get('pictograms')
													const filtered = pictograms.filter(function(p) {
														return !xhr.data.some(s => s.code === p.id)
													});
													viewModel.set('pictograms', filtered)
													$('#pictogramDescription').text('')
													$('#pictogramFileUpload').val('')
													NM.util.openModal( AP.fontFamily.fields.pictogramRoot );

												}
											},
										},
									} )
								);
							}
						},
					},
				} );
			}

			return false;
		},
	} );

	pub.edit = function( id, name ) {
		viewModel.resetForm();
		
		NM.util.ajax( {
			method: "GET",
			url: `/manager/ajax/font-family/${id}/pictograms`,
			callback: {
				done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {

                        viewModel.get( "detailForm.data.fontFamilyPictograms" ).data( xhr.data );
                        viewModel.set( "detailForm.title", "Pittogrammi Font Family < " + name + " >" );
						var pictograms = viewModel.get('pictograms')
						const filtered = pictograms.filter(function(p) {
							return !xhr.data.some(s => s.code === p.id)
						});
						viewModel.set('pictograms', filtered)
                        NM.util.openModal( AP.fontFamily.fields.pictogramRoot );

                    }
				},
			},
		} );

		$("#pictogramFileUpload").on("change", function(e) {
			const file = e.target.files[0];
			if (file) {
				const reader = new FileReader();
				reader.onload = function(evt) {
					const base64 = evt.target.result;
					viewModel.set("detailForm.data.pictogram.image", base64);
					viewModel.checkCanSave()
				};

				reader.readAsDataURL(file);
			}
		});

		viewModel.set('detailForm.data.id', id)
		viewModel.set('detailForm.data.name', name)
	};

	pub.init = function() {
		kendo.bind( AP.fontFamily.fields.pictogramRoot, viewModel );
		AP.page.pictogramCodes.unshift({ "id": "", "name": "-- Seleziona un pittogramma"})
		viewModel.set( 'pictograms', AP.page.pictogramCodes );

		var detailForm = AP.fontFamily.fields.pictogramForm;

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
							id: function() {
								return viewModel.get( "detailForm.data.id" );
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

AP.fontFamily.list = ( function() {
    var pub = {};

    var detailApp = AP.fontFamily.detail;
    var pictogramApp = AP.fontFamily.pictogram;

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

        editPictograms: function( event ) {
            pictogramApp.edit( event.data.id, event.data.name );

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