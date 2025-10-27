component extends=".Application" {

    this.name        = "apirone-resources";
    this.nullSupport = true;

	public Boolean function OnRequestStart( string targetPage ) {

        //super.onRequestStart();

        var allowedIPs = "127.0.0.*,185.6.241.249,79.19.179.30,194.183.87.112,185.52.113.41,192.168.*,10.0.*";

        var ip = getRealIP();
        
        if ( !IsIPInRange( allowedIPs, ip ) ) {

            cfheader(statuscode="404", statustext="Not Found");
            echo("Not allowed");
            abort;

        }

        if( url.KeyExists("fwreinit") AND fwreinit == 1 OR !application.keyExists("cbBootstrap") ) {
            super.loadColdbox()
        }

        if( url.KeyExists("reset") ) {
            super.clearContainer();
        }

        application.cbBootstrap.onRequestStart( arguments.targetPage );

        return true;

    }

	private function getRealIP(){

        var headers = GetHTTPRequestData().headers;

        if ( StructKeyExists( headers, "x-cluster-client-ip" ) ) {
			return headers[ "x-cluster-client-ip" ];
		}
		if ( StructKeyExists( headers, "X-Forwarded-For" ) ) {
			return headers[ "X-Forwarded-For" ];
		}

		return Len( CGI.REMOTE_ADDR ) ? Trim( listFirst( CGI.REMOTE_ADDR ) ) : "999.999.999.999";

    }

}
