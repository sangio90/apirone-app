component extends="com.apirone.core.root.Application" {

    this.name        = "apirone-resources";
    this.nullSupport = true;

	public Boolean function OnRequestStart( string targetPage ) {

        var allowedIPs = "127.0.0.1,185.6.241.249,79.19.179.30";

        var ip = getRealIP();

        if ( !ListFind( allowedIPs, ip ) ) {

            cfheader(statuscode="404", statustext="Not Found");
            echo("Not allowed");

            abort;

        }

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
