/**
 * AbsService class
 * @author Roberto Marzialetti <roberto@marzialetti.com>
 * @since 19/02/2020
 */

 component output="false" accessors="true" {

    property name="logger" type="com.apirone.core.util.Logger";
    property name="factory" type="com.apirone.core.model.factory.Factory";
    property name="cacheManager" type="com.apirone.core.util.CacheManager";
	property name="configuration" type="com.apirone.core.model.bean.Configuration" ;

    /**
     * @param type - il nome del bean
     * @param scope - la cartella
     * @param values - dati inuna struttura
     */

    public com.apirone.core.model.bean.AbsBean function bean(
        required String type, 
                 String scope="core", 
                 Struct values={} 
    	){

        return getFactory().createInstance( argumentCollection = arguments );

    }

    public com.apirone.core.model.bean.Error function getError(){

    	return CreateObject("component", "com.apirone.core.model.bean.Error");

    }

    public com.apirone.core.model.bean.Result function getResult(){

    	var bean = new com.apirone.core.model.bean.Result();

        return bean;

    }

    public String function createOrderBy(required Array fields=[]) {
        
        var result = "";
        var n = 1;
        
        for ( var i in arguments.fields ) {

           
            if ( !StructKeyExists( i, 'sort' ) ) {
                i.sort = "ASC";
            }

            if ( !ListFind( "ASC,DESC", i.sort ) ) {

                throw( 
                    message="Sort [#i.sort#] not valid for field [#i.field#]. Only accepted values are ASC or DESC", 
                    type="zerobenefit.errors.AbsService.SortValueNotValid" 
                );

            }
            
            result = result & "#getDBField( i.field )# #i.sort#";

            result = arguments.fields.len() EQ n ? result : result & ", ";
            
            n++;

        }

        return result;
    }
    
    public String function getDBField( required String field ) {

        var fields = DESerializeJSON( FileRead( ExpandPath('/config/DBFields.json.cfm') ) );
 
        if ( !structKeyExists( fields, arguments.field ) ) {

            throw( 
                message="Field [#arguments.field#] not found in available values.",
                type="zerobenefit.errors.AbsService.DBFieldNotFound" 
            );

        }

        return LCase( fields[ arguments.field ] );
    }
    
}