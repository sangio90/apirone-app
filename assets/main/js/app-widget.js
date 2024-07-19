(function(){

	CRD.namespace("CRD.widget");

	CRD.widget.grid = function( setup ) {

	 	var defaults = {
	 		element: null,
	    	url: null,
	    	//columns: [],
	    	scrollable: false,
	    	pageable: true,
	    	sortable: true,
	    	pageSize: CRD.config.rpp,
	    	serverPaging: true,
			dataBound: null,
	    	rowTemplate: null
	  	}

	  	var settings = $.extend( true, defaults, setup );
	  	var ds = null;

		if ( settings.url ) {
			
			ds = CRD.dataSource({
				type: "json",
				transport: {
					read: settings.url
				},
				pageSize: settings.pageSize,
				schema: {
					data: "data",
					total: "total"
				}
			})

		}

		var dataWidget = settings.element.kendoGrid( {
	  		scrollable: settings.scrollable,
	    	dataSource: ds,
	    	columns: settings.columns,
	    	pageable: settings.pageable,
	    	rowTemplate: settings.rowTemplate,
	    	dataBound: settings.dataBound
	  	} ).data( 'kendoGrid' );


	    dataWidget.bind( "dataBound", function() {

			//var status = dataWidget.element.parent('.k-grid').prev('.grid-status');
			var wrapper = dataWidget.wrapper;
			var status = wrapper.prev( ".grid-status" );
	    	var count = dataWidget.dataSource.view().length;

	    	if ( count > 0 ) {
	    		wrapper.show();
	    		status.addClass( "d-none" );
	    	} else {
	    		wrapper.hide();
	    		status.removeClass( "d-none" );
	    		CRD.widget.status( { element: status, message: "Non ci sono record" } );
	    	}

	    })


	 	if ( settings.pageable != null ) {

	 		//TODO

	    }   

	  	return dataWidget;

	}

	CRD.widget.notify = function( text, type ) {

	 	var settings = {
	    	heading: text,
	    	position: "top-right",
	    	loaderBg: "#ff6849",
	    	icon: type,
			hideAfter: 4000, 
			stack: 6
	  	}

		$.toast( settings );

	}

	CRD.widget.suggest = function( setup ) {

	 	var defaults = {
	    	element: null,
	    	url: null,
	    	data: null,
	    	dataValueField: null,
	    	dataTextField: null,
	    	resultFunction: 'default',
	    	change: null,
	    	minLength: 3,
	    	allowClear: true,
	    	callbacks: {
	    		select: null
	    	}
	  	}

	  	var settings = $.extend( true, defaults, setup );

		var dataWidget = settings.element.select2({
			templateResult: CRD.utils.suggestTemplates[ settings.resultFunction ],
	    	allowClear: settings.allowClear,
	    	placeholder: settings.placeholder,
		    minimumInputLength: settings.minLength,
		    dropdownParent: settings.parent,

			escapeMarkup: function( markup ){
				return markup; 
			},

			ajax: {
		   		delay: 250,
		   		url: settings.url,

		    	data: function(params) {
		      		var query = {
		        		str: params.term,
		      		}
		      		return query;
		    	},
			    
			    processResults: function (data) {

					var rows = $.map( data.data, function( obj ) {
				  		obj.id = obj.id || obj[ settings.fields.id ]; 
				  		obj.text = obj.text || obj[ settings.fields.text ];
				  		return obj;
					});

			      	return {
		                results: rows
					}

			    }

		  	}
		});

		if ( settings.value.id  ) { //imposto il default
		    var opt = new Option( settings.value.text, settings.value.id, true, true);
		    settings.element.append( opt ).trigger('change');
		}

		if ( settings.callbacks.select ) {

			settings.element.on('select2:select', function ( event ) {
				settings.callbacks.select( event )
			});

		}

	  	return dataWidget;

	}

	CRD.widget.datePicker = function( setup ) {

	 	var defaults = {
	    	element: null,
            start: null,
            depth: null,
            format: null,
            dateInput: null
	  	}

	  	var settings = $.extend( true, defaults, setup );

		var dataWidget = settings.element.kendoDatePicker( {
            start: settings.start,
            depth: settings.depth,
            format: settings.format,
            dateInput: settings.dateInput
	  	} ).data( 'kendoDatePicker' );

		/*
			HTML per il datepicker di Kendo
			<span>
			    <span>
			        <input><span icon>
			    </span>
			</span>
		*/
		settings.element.parent().removeAttr('class');
		settings.element.parent().parent().removeAttr('class');
		settings.element.removeClass('k-input');

		settings.element.bind("click", function() {
			dataWidget.open();
		});

		return dataWidget;

	}

	CRD.widget.status = function( setup ) {

	 	var defaults = {
	    	element: null,
	    	message: "",
	    	type: "info", //info, success, danger, warning
	  	}

	  	var settings = $.extend( true, defaults, setup );

	  	var classes  = "";

		switch( settings.type ) {
			case "success":
		    	classes = "alert alert-success";
		    	break;
		  	case "danger":
		    	classes = "alert alert-danger";
		    	break;
		  	case "warning":
		    	classes = "alert alert-warning";
		    	break;
		  	default:
		    	classes = "alert alert-info"
		}

		settings.element.removeClass( "alert-success alert-danger alert-warning alert-info" );

		settings.element.addClass( classes ).html( settings.message );

	  	return settings;

	}

}());
