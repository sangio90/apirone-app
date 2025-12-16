<cfscript>
private Void function notifyVerticale(){

	var user = "apikey";
	var pwd = "Gs16072001!";
	var secret = ToBase64('#user#:#pwd#');

	cfhttp( url = "http://194.183.87.112:8080/verticale_web_data/servlet/api/v1/apir_update_articoli/ALL", method = "POST", result="result" ) {
		cfhttpparam( type = "header", name = "Content-Type", value = "application/json" );						
		cfhttpparam( type = "header", name = "Authorization", value = "Basic #secret#" );							
	}

	cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# notifyVerticale: apir_update_articoli: status: #result.status_code#");

	cfhttp( url = "http://194.183.87.112:8080/verticale_web_data/servlet/api/v1/apir_update_ordini/ALL", method = "POST", result="result" ) {
		cfhttpparam( type = "header", name = "Content-Type", value = "application/json" );						
		cfhttpparam( type = "header", name = "Authorization", value = "Basic #secret#" );							
	}

	cffile( action="APPEND" file="#ExpandPath('/debug.log')#" output="#now()# notifyVerticale: apir_update_ordini: status: #result.status_code#");
	
}	
</cfscript>


<cfset notifyVerticale() />