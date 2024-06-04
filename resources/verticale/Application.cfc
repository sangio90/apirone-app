component{

    pageEncoding "UTF-8";

    this.name = "verticale-apir-server";

    this.datasources["verticale"] = {
        class: "com.microsoft.sqlserver.jdbc.SQLServerDriver", 
        bundleName: "org.lucee.mssql", 
        bundleVersion: "12.2.0.jre8",
        connectionString: "jdbc:sqlserver://194.183.87.112:1434;DATABASENAME=verticale;SelectMethod=direct",
        username: "sa",
        password: "encrypted:d721ad8ece5fda102e2ebca5613f6f3cd0dea73325475de5d1b0bf665a053071",
        
        // optional settings
        connectionLimit:-1, // default:-1
        liveTimeout:15, // default: -1; unit: minutes
        validate:false, // default: false
    };


    public boolean function onRequestStart(){

        return true

    }

}
