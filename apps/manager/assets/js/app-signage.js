AP.namespace( "signage" );

Object.assign( AP.signage.fields, {
    modalRoot: $( "#signage-modal" )
} );

$( document ).ready( function() {
    if ( AP.signage.fields.modalRoot.length ) {
        AP.signage.modal.init();
    }
} );

AP.signage.modal = ( function() {
    var pub = {};

    var defaultDetailForm = {
        data: {
            id: "",
            code: "",
            name: "",
            signageLines: new kendo.data.DataSource(),
            pictogramNames: [
                '<dx>',
                '<giu>',
                '<lift>',
                '<man>',
                '<pmr>',
                '<su>',
                '<sx>',
                '<wom>'
            ],
            parsedPictograms: function() {
                    return this.pictogramNames.map(p => {
                        let name = p.replace(/[<>]/g, '');
                        return {
                            label: name,
                            image: `<img src="/assets/main/pictograms/${name}.png" alt="${name}" class="pictogram px-2">`
                        }
                    });
                },
            pictogramHelper: false,
            category: {
                id: "",
            },
            line: {
                id: "",
            },
            model: {
                id: "",
            },
            finish: {
                id: "",
            },
            signageConfig: {
                id: "",
            },
            font: {
                id: "",
            },
            fontSize: {
                id: "",
            },
            nameItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT"
                }
            },
            descriptionItem: {
                id: "",
                name: "",
                lang: {
                    id: "IT"
                }
            },
            status: {
                id: "ACT",
            },
        },
        statuses: AP.page.statuses,
        title: "Carica segnaletica",
    };

    var viewModel = kendo.observable( {
        detailForm: defaultDetailForm,
        categories: new kendo.data.DataSource(),
        lines: new kendo.data.DataSource(),
        models: new kendo.data.DataSource(),
        finishes: new kendo.data.DataSource(),
        signageConfigs: new kendo.data.DataSource(),
        fonts: new kendo.data.DataSource(),
        fontSizes: new kendo.data.DataSource(),
        signageImages: new kendo.data.DataSource(),

        callback: {
            onCreate: undefined,
            onUpdate: undefined,
            onLoad: undefined,
        },

        resetForm: function() {},

        getSignageConfig: function() {
            const fontId = viewModel.get( "detailForm.data.font.id" );
            for ( var signageConfig of viewModel.get( "signageConfigs" ).data() ) {
                if ( signageConfig.font.id == fontId ) {
                    return signageConfig;
                }
            }
        },

        addSignageLine: function() {     
            var defaultSignageLine = {
                id: "",
                textAlign: "center",
                content: "",
                orderby: viewModel.get('detailForm.data.signageLines').data().length + 1
            };       
            viewModel.get('detailForm.data.signageLines').add(defaultSignageLine);

            return false;
        },
    
        togglePictogramHelper: function(e) {
            if (viewModel.get('detailForm.data.pictogramHelper') == false) {
                $('#pictogram-helper-modal').modal('show');
                viewModel.set('detailForm.data.pictogramHelper', true);
            } else {
                $('#pictogram-helper-modal').modal('hide');
                viewModel.set('detailForm.data.pictogramHelper', false);
            }
        },

        parsedLineContent: function(e) {
            const contentSpanPreview = $('#content_span_preview_' + e.data.orderby);
            
            if (contentSpanPreview.length == 1) {
                var valore = e.currentTarget.value;
                const pictogramNames = viewModel.get('detailForm.data.pictogramNames');
                var pictograms = pictogramNames.filter(function(pictogramName) {
                    return valore.includes(pictogramName);
                });
                pictograms.forEach(function(pictogram) {
                    valore = valore.replace(pictogram, '<img src="/assets/main/pictograms/' + pictogram.replace(/[<>]/g, '') + '.png" alt="' + pictogram.replace(/[<>]/g, '') + '" class="pictogram px-2">');
                })
                contentSpanPreview.html(valore);
            }
            
            return false;
        },

        removeSignageLine: function(e) {
            const uid = e.data.uid
            const row = viewModel.get('detailForm.data.signageLines').getByUid(uid);
            viewModel.get('detailForm.data.signageLines').remove(row);
            return false;
        },

        setTextAlign: function (e) { 
            var uid = e.data.uid
            var signageLine = viewModel.get('detailForm.data.signageLines').getByUid(uid);
            signageLine.set('textAlign', $(e.currentTarget).data('value') );
            $(e.currentTarget).addClass('selected-text-align').siblings().removeClass('selected-text-align');
        },

        updateLine: function( e ) {
            const uid = e.data.uid;
            const line = viewModel.get( "detailForm.data.lines" ).getByUid( uid );
            line.set( "id", new Date() );

            return false;
        },

        loadLines: function( event ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/lines/" + viewModel.get( "detailForm.data.category.id" ),
                callback: {
                    done: function( xhr ) {
                        viewModel.get( "lines" ).data( xhr.data );
                        NM.util.openModal( AP.signage.fields.modalRoot );
                    },
                },
            } );
        },

        loadModels: function( event ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/models/" + viewModel.get( "detailForm.data.line.id" ),
                callback: {
                    done: function( xhr ) {
                        viewModel.get( "models" ).data( xhr.data );
                        NM.util.openModal( AP.signage.fields.modalRoot );
                    },
                },
            } );
        },

        loadFinishes: function( event ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/finishes/" + viewModel.get( "detailForm.data.category.id" ) + "/" + viewModel.get( "detailForm.data.line.id" ),
                callback: {
                    done: function( xhr ) {
                        viewModel.get( "finishes" ).data( xhr.data );
                        NM.util.openModal( AP.signage.fields.modalRoot );
                    },
                },
            } );
        },

        loadSignageConfigs: function( event ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/quotations/signage-configs?categoryId="
                    + viewModel.get( "detailForm.data.category.id" )
                    + "&lineId="
                    + viewModel.get( "detailForm.data.line.id" )
                    + "&modelId="
                    + viewModel.get( "detailForm.data.model.id" ),
                callback: {
                    done: function( xhr ) {
                        const fonts = [];

                        for ( var font of xhr.data ) {
                            fonts.push( font.font );
                        }
                        viewModel.get( "fonts" ).data( fonts );
                        viewModel.get( "signageConfigs" ).data( xhr.data );

                        if ( fonts.length === 1 ) {
                            viewModel.set( "detailForm.data.font.id", fonts[0].id );
                            viewModel.get( "fontSizes" ).data( xhr.data.items );
                        }

                        NM.util.openModal( AP.signage.fields.modalRoot );
                    },
                },
            } );
        },

        loadFontSizes: function() {
            viewModel.get( "fontSizes" ).data( viewModel.getSignageConfig().items );
        },

        save: function( event ) {
            var detailForm = AP.signage.fields.detailForm;
            var status = detailForm.find( ".status" );

            status.html(
                "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>",
            );

            if ( detailForm.valid() ) {
                NM.util.ajax( {
                    method: "POST",
                    url: "/manager/ajax/signages",
                    data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                    callback: {
                        done: function( xhr ) {
                            if ( xhr.status == "SUCCESS" ) {
                                NM.util.autoHideMessage(
                                    status,
                                    "<span class='green'>Segnaletica salvata</span>",
                                );

                                setTimeout(
                                    () => $( "#signage-detail-modal" ).modal( "hide" ),
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

    pub.new = function( onSave ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/quotations/categories",
            callback: {
                done: function( xhr ) {
                    viewModel.get( "categories" ).data( xhr.data );
                    NM.util.openModal( AP.signage.fields.modalRoot );
                },
            },
        } );


    };

    pub.edit = function( { id, onSave } ) {
        if ( onSave ) {
            viewModel.set( "callback.onSave", onSave );
        }

        viewModel.resetForm();

        NM.util.ajax( {
            method: "GET",
            url: "/manager/ajax/signages/" + id,
            callback: {
                done: function( xhr ) {
                    if ( xhr.status == "SUCCESS" ) {
                        var selectedCategories = [];

                        if ( xhr.data?.categories ) {
                            for ( var category of xhr.data.categories ) {
                                selectedCategories.push( category );
                            }
                        }

                        viewModel.set( "detailForm.data", xhr.data );
                        viewModel.set(
                            "detailForm.data.selectedCategories",
                            selectedCategories,
                        );
                        viewModel.set( "detailForm.title", "Modifica segnaletica" );

                        NM.util.openModal( AP.signage.fields.modalRoot );
                    }
                },
            },
        } );
    };

    pub.init = function() {
        kendo.bind( AP.signage.fields.modalRoot, viewModel );

        var signageLines = new kendo.data.DataSource();
        var loadedSignageLines = [];
        //TODO a tendere dovremo riceverle quando aprimo la modale della segnaletica (AP.page.signageLines)

        for ( var signageLine of loadedSignageLines ) {
            var newSignageLine = {
                id: font.id,
                textAlign: signageLine.textAlign,
                content: signageLine.content,
                orderby: signageLine.orderby
            };

            signageLines.add( newSignageLine );
        }

        viewModel.get( "detailForm.data.signageLines", signageLines );
    };

    return pub;
} () );
