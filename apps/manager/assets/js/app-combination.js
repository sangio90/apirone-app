AP.combination = AP.combination || {};

AP.combination.fields = {
    rootDetail: $("#combination-detail-root"),
	configRow: $("#combination-config-row")
}

$(document).ready(function(){

	if ( AP.combination.fields.rootDetail.length ) {

		AP.combination.list.init();

	}

})


AP.combination.list = function() {

	var pub = {}
	
	var service = AP.attribute.detail;

	var dataSources = {
		items: NM.kendo.dataSource( { url: "/manager/ajax/combinations/" + AP.page.combinationId + "/items" } )
	}

	var viewModel = kendo.observable({

		items: dataSources.items,
		attributesList: [],

		selectAttribute: function( event ) {

			console.log( event );

			$.ajax({
				method: "POST",
				url: "/manager/ajax/combinations/" + AP.page.combinationId + "/items",
				data: { 
					attributeId: event.data.id 
				},
				success: function(xhr) {

					viewModel.getItems()

				},
			});

		},

		showTable: function() {

			return viewModel.get("items").view().length ? true : false;

		},

        showComponents: function( event ) {

			$("#component-list-modal").modal("show");

            return false;
		},

		getItems: function( event ) {
			
			viewModel.get("items").read()

		},

		getAttributeName: function( event ) {

			var text = AP.util.getMainText( event.texts )

			return text.name;

		},

		addAttribute: function( event ) {

			service.open( { id: '' } );

			return false;
		},

		showAttributesList: function() {

			NM.util.openModal( $("#line-attributes-list-modal") );

			this.searchAttributes()

		},

		showImagesList: function() {

			NM.util.openModal( $("#combination-images-list-modal") );

		},

		showAttributeValues: function( event ) {

			console.log("event.data.id", event.data.id)

			service.open( 
				{ 
					id: event.data.id,
					callback: { 
						onSave: function() {
							viewModel.searchAttributes();
						},
					} 
				}
			)

			return false;

		},

		searchImages: function( event ) {

			console.log("searchImages");

			var str = $('#attributes-search-input').val();
			var status = $('#attributes-list-search-form .status');

			status.html('Sto cercando...')

			$.ajax({
				method: "GET",
				url: "/manager/ajax/attributes",
				data: 'str=' + str,
				success: function(xhr) {
					viewModel.set( "attributesList", xhr.data );
					status.html( "Ho trovato " + xhr.count + " record.") 
				},
			});

            return false;

		},				

		searchAttributes: function( event ) {

			console.log("searchAttributes");

			var str = $("#attributes-search-input").val();
			var status = $("#attributes-list-search-form .status");

			status.html("Sto cercando...")

			$.ajax({
				method: "GET",
				url: "/manager/ajax/attributes",
				data: "str=" + str,
				success: function(xhr) {
					viewModel.set( "attributesList", xhr.data );
					status.html( "Ho trovato " + xhr.count + " record.") 
				},
			});

            return false;

		},

		initUpload: function() {

			var documents = viewModel.get( "documents" ).data();
			var shipmentId = viewModel.get( "shipment.id" );

			if( documents.length > 0 ) {

				var modal = $('#documents-upload-modal');
				modal.modal( "show" );

				for ( var document of documents ) {
				
					var uid = document.uid;

					$('#document-upload-' + uid ).fileupload({
						dropZone: $('#document-upload-dropzone-' + uid),
						autoUpload: true,
						formData: { "shipmentId": shipmentId, "documentTypeId": document.id },
						url: '/manager/ajax/shipment/upload-document',
						add: function (event, data) { 
							var uid = $(event.target).data("uid");
							
							var status = $('#document-upload-status-' + uid );
							
							status.html("");
							
							//TODO: get list form configuration
							if (!(/\.(jpg|jpeg|png|pdf)$/i).test(data.files[0].name)) {
								status.html('<span class="error">File non ammesso. Consentiti: jpg, jpeg, png, pdf.</span>');
								return false;
							}
	
							data.submit();
	
						},
			
						progressall: function( event, data ) {
	
							var status = $('#document-upload-status-' + uid );
							status.html("");
	
							var uid = $(event.target).data("uid");
							
							var progress = parseInt(data.loaded / data.total * 100, 10);
							$('#document-upload-progress-' + uid + ' .upload-bar').css('width', progress + '%');
							
							status.html('Fatto!');
							
							var row = viewModel.get("documents").getByUid( uid );
							
							row.set("completed", true);
	
						}
					});		
	
				}				

			} else {

				viewModel.showPaymentDialog();

			}

		},

		isDocumentCompleted: function( event ) {

			var item = viewModel.get("documents").getByUid( event.uid );

			if( !event.completed ) {
				return true;
			}

			return false;

		},

		isDocumentsUploadUncompleted: function( event ) {

			var items = viewModel.get("documents").data();

			for( var item of items ) {
				if ( !item.completed ) {
					return true;
				}
			}

			return false;

		},

		isDocumentUncompleted: function( event ) {

			return !this.isDocumentCompleted( event );

		},		

		loadFishes: function() {

			var thisForm  = AP.combination.fields.configRow;
			var finishEle = thisForm.find("[name=finishId]");
			var sizeEle = thisForm.find("[name=sizeId]");

			var lineId = AP.page.lineId;
			var sizeId = sizeEle.val();
			var combinations = AP.page.combinations;
			var combinationId = AP.page.combinationId;

			finishEle.empty("");
			
			finishEle.append(
				$("<option>", { 
					value: '',
					text : '-- seleziona'
				})
			);

			finishEle.val( "" );
			
			var found = false;
			
			combinations.forEach(function( combination ) {

				if( 
					lineId == combination.line.id 
					&& sizeId == combination.size.id 
				) {

					if ( combination.id == combinationId ) {
						found = true;
					}

					var opt = $("<option>", { 
						value: combination.id,
						text : AP.util.getMainText( combination.finish.texts ).name
					})

					finishEle.append( opt );
					
				}
				
			});

			found ? finishEle.val(  AP.page.combinationId ) : '';

            return false;

		},		

		change: function( event ) {

			var thisId = $(event.currentTarget).val();

			if( thisId != AP.page.combinationId && thisId.length ) {

            	window.location.href = "/manager/combinations/" + thisId;
			
			}

            return false;

		},		

    });   	

	pub.init = function() {

		kendo.bind( AP.combination.fields.rootDetail, viewModel )

		viewModel.loadFishes();	
	
	}	

	return pub;

}();