AP.role = AP.role || {};

AP.role.fields = {
    rolesList: $( "#role-list-root" ),
    rolePermissions: $( "#role-permissions-modal" ),
    rolePermissionsForm: $( "#role-permissions-form" ),
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
            },
            title: "",
            entities: new kendo.data.DataSource()
        };
    }

    var viewModel = kendo.observable( {
        detailForm: getDefaultDetailForm(),

        getPermissions: function() {
            NM.util.ajax( {
                method: "GET",
                url: "/manager/ajax/roles/" + viewModel.get( "detailForm.data.id" ) + "/permissions?entityId=" + viewModel.get( "detailForm.data.entity.id" ),
                callback: {
                    done: function( xhr ) {
                        if ( xhr.status == "SUCCESS" ) {
                            viewModel.set( "detailForm.data.entity.permissions", xhr.data );
                            $( "#permission-grid" ).removeClass( "hidden" );
                        }
                    },
                },
            } );
        },

        save: function( event ) {

            NM.util.ajax( {
                method: "POST",
                url: "/manager/ajax/roles-permissions",
                data: JSON.stringify( viewModel.get( "detailForm.data" ) ),
                callback: {
                    done: function( xhr ) {
                        if ( xhr.status == "SUCCESS" ) {

                            status.html( "" );

                            AP.widget.notify( "success", xhr.data.message.text );

                            setTimeout( () => {
                                fields.rolePermissions.modal( "hide" );
                            }, 700 );

                        }
                    },
                },
            } );

            return false;
        },
    } );

    pub.edit = function( role ) {
        viewModel.set( "detailForm", getDefaultDetailForm() );

        // $('#permission-grid').addClass('hidden')
        viewModel.set( "detailForm.title", "Modifica Ruoli < " + role.name + " >" );
        viewModel.set( "detailForm.data.id", role.id );
        viewModel.set( "detailForm.data.name", role.name );
        var entities = AP.page.entities.slice();
        entities.unshift( { "id": "", "name": "-- Seleziona un Entità" } );
        viewModel.set( "detailForm.entities", entities );

        NM.util.openModal( fields.rolePermissions );
    };

    pub.init = function() {

        kendo.bind( AP.role.fields.rolePermissions, viewModel );

    };

    return pub;

}() );


AP.role.list = ( function() {

    var pub = {};
    var rolePermissions = AP.role.detail;

    var dataSources = {
        items: AP.page.roles,
    };

    var viewModel = kendo.observable( {
        rows: dataSources.items,
        edit: function( event ) {
            rolePermissions.edit( event.data );

            return false;
        }
    } );

    pub.init = function() {
        kendo.bind( AP.role.fields.rolesList, viewModel );
    };

    return pub;
}() );
