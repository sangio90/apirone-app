var NM = {};
NM.kendo = NM.kendo || {};

NM.kendo.dataSource = function( config = {} ) {

    var defaults = {
        data: config.data ? config.data : [],
        params: config.params ? config.params : {},
        pageSize: config.count ? config.count : 15,
        serverSorting: config?.serverSorting ? config?.serverSorting : false,
        serverFiltering: config?.serverFiltering ? config.serverFiltering : false,
        serverPaging: config?.serverPaging ? config.serverPaging : true,

        change: function() {
            $.each( this.data(), function( index, item ) {
                item.set( "index", index+1 );
            } );
        }
    };

    defaults.schema = { "data": "data", "total": "total" };

    if ( "url" in config ) {

        // defaults.serverPaging = true;
        defaults.transport = {
            read: {
                url: config.url
            }
        };

        defaults.transport.parameterMap = function( params, type ) {

            // merge
            Object.assign( params, config.params );

            // remove default value from datasource
            params.count = params.pageSize;
            delete params.pageSize;
            delete params.skip;
            delete params.take;

            // add query string to pager ajax call
            defaults.transport.read.data = params;

            return params;
        };

        if( config.requestStart ) {
            defaults.requestStart = config.requestStart;
        }

        if( config.requestEnd ) {
            defaults.requestEnd = config.requestEnd;
        }

        if ( config.model ) {
            defaults.schema.model = config.model;
        }

    }

    if ( "serverFiltering" in config ) {
        defaults.serverFiltering = config.serverFiltering;
    }

    if ( "serverPaging" in config ) {
        defaults.serverPaging = config.serverPaging;
    }

    var dataSource = new kendo.data.DataSource( defaults );

    return dataSource;

};

/*
    remove scrollbar in grid
*/
NM.kendo.toggleScrollbar = function( event ) {
    var gridWrapper = event.sender.wrapper;
    var gridDataTable = event.sender.table;
    var gridDataArea = gridDataTable.closest( ".k-grid-content" );

    var ele = event.sender.element.prop( "id" );

    gridWrapper.addClass( "no-scrollbar" );

    var grid = $( "#" + ele );

    var checkboxes = grid.find( ".form-check-input" );
    var lastChecked = null;

    checkboxes.click( function( e ) {
        if ( !lastChecked ) {
            lastChecked = this;
            return;
        }

        if ( e.shiftKey ) {
            var start = checkboxes.index( this );
            var end = checkboxes.index( lastChecked );

            checkboxes.slice( Math.min( start, end ), Math.max( start, end ) + 1 ).prop( "checked", lastChecked.checked );
        }

        lastChecked = this;
    } );

};

NM.kendo.formatDate = function( date, type="normal" ) {
    // example date, from server: July, 13 2022 10:50:39 +0200, culture: en-US

    if ( type == "normal" ) {
        var ret = kendo.toString( kendo.parseDate( date, "MMMM, dd yyyy HH:mm:ss", "en-US" ), "dd/MM/yyyy HH:mm" );
    }

    if ( type == "date-only" ) {
        var ret = kendo.toString( kendo.parseDate( date, "MMMM, dd yyyy HH:mm:ss", "en-US" ), "dd/MM/yyyy" );
    }

    if ( type == "short" ) {
        var ret = kendo.toString( kendo.parseDate( date, "MMMM, dd yyyy HH:mm:ss", "en-US" ), "dd/MM" );
    }

    return ret;
};

// for Mementify dates (ISO 8601)
NM.kendo.formatISODate = function( date, type = "normal" ) {

    var parsed = kendo.toString( kendo.parseDate( date, "yyyy-MM-dd HH:mm:ss" ), "MMMM, dd yyyy HH:mm:ss" );

    var ret = NM.kendo.formatDate( parsed, type );

    return ret;
};