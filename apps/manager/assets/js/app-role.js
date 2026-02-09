AP.namespace( "role" );

AP.role.fields = {
    rolesList: $( "#role-list-root" ),
    rolePermissions: $( "#role-permissions-modal" ),
    rolePermissionsForm: $( "#role-permissions-form" ),
    roleDetailModal: $( "#role-detail-modal" ),
};

$( document ).ready( function(){

    if ( AP.role.fields.rolesList.length ) {
        AP.role.list.init();
    }

    if ( AP.role.fields.rolePermissions.length ) {
	    AP.role.detail.init();
    }

} );

AP.role.detail = ( function() {

    var pub = {};

    var fields = AP.role.fields;

    function getDefaultDetailForm() {
        return {
            data: {
                entity: {
                    id: "",
                    name: "",
                    permissions: new kendo.data.DataSource()
                },
                id: "",
                name: "",
                quotationMaxDiscount: "0",
                quotationMaxAmount: "0",
            },
            title: "",
            entities: new kendo.data.DataSource()
        };
    }

    var viewModel = kendo.observable( {
        detailForm: getDefaultDetailForm(),

        getCreatedAt: function( event ) {
            return NM.kendo.formatISODate( event.createdAt );
        },

        selectAll: function( event ) {
            NM.util.checkAll( event.currentTarget );
            viewModel.get( "detailForm.data.entity.permissions" ).forEach( ( permission ) => permission.active = event.currentTarget.checked );

            return false;
        },

        getPermissions: function() {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/roles/" + viewModel.get( "detailForm.data.id" ) + "/permissions?entityId=" + viewModel.get( "detailForm.data.entity.id" ),
                callback: {
                    done: function( xhr ) {
                        viewModel.set( "detailForm.data.entity.permissions", xhr.data );
                        $( "#permission-grid" ).removeClass( "hidden" );
                    },
                },
            } );
        },

        getRole: function( roleId ) {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/roles/" + roleId,
                callback: {
                    done: function( xhr ) {

                        viewModel.set( "detailForm.data.id", xhr.data.id );
                        viewModel.set( "detailForm.data.name", xhr.data.name );
                        viewModel.set( "detailForm.data.quotationMaxAmount", xhr.data.quotationMaxAmount );
                        viewModel.set( "detailForm.data.quotationMaxDiscount", xhr.data.quotationMaxDiscount );

                    },
                },
            } );
        },

        savePermissions: function( event ) {
            var thisForm = AP.role.fields.rolePermissionsForm;
            var status = thisForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/roles-permissions",
                data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                callback: {
                    done: function( xhr ) {
                        status.html( "" );
                        AP.widget.notify( "success", xhr.data.message.text );

                        viewModel.getPermissions();

                    },
                },
            } );

            return false;
        },

        save: function( event ) {
            var thisForm = AP.role.fields.rolePermissionsForm;
            var status = thisForm.find( ".status" );

            status.html( "<img src='/assets/main/img/ajax-loading.svg' width='20' height='20'>" );

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/roles",
                data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                callback: {
                    done: function( xhr ) {
                        status.html( "" );
                        AP.widget.notify( "success", "Ruolo salvato con successo" );
                    },
                },
            } );

            return false;
        },
    } );

    pub.edit = function( role ) {

        viewModel.set( "detailForm.title", "Modifica < " + role.name + " >" );

        kendo.bind( AP.role.fields.roleDetailModal, viewModel );

        viewModel.getRole( role.id );

        NM.util.openModal( fields.roleDetailModal );
    };

    pub.editPermissions = function( role ) {
        viewModel.set( "detailForm", getDefaultDetailForm() );

        var entities = AP.page.entities.slice();

        viewModel.set( "detailForm.title", "Modifica permessi per < " + role.name + " >" );
        viewModel.set( "detailForm.data.id", role.id );
        viewModel.set( "detailForm.data.name", role.name );

        entities.unshift( { "id": "", "name": "-- Seleziona una entità" } );
        viewModel.set( "detailForm.entities", entities );

        NM.util.openModal( fields.rolePermissions );
    };

    pub.init = function() {

        kendo.bind( AP.role.fields.rolePermissions, viewModel );
        $( document ).on( "click", "[name=\"selectAll\"]", function( e ) {
            viewModel.selectAll( e );
        } );

    };

    return pub;

}() );


AP.role.list = ( function() {

    var pub = {};
    var detailApp = AP.role.detail;
    var fields = AP.role.fields;

    var dataSources = {
        items: AP.page.roles,
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,
        editPermissions: function( event ) {

            detailApp.editPermissions( event.data );

            return false;
        },
        edit: function( event ) {

            detailApp.edit( event.data );

            return false;
        }
    } );

    pub.init = function() {
        kendo.bind( fields.rolesList, viewModel );
    };

    return pub;
}() );
