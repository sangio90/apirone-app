<cfoutput>
AP.data = {};

AP.config = {}
AP.config.regexp = {};
AP.config.regexp.pwd = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(.*){8,}$/;

<cfloop collection="#prc.structData#" item="item">
    AP.data['#item#'] = #SerializeJSON( prc.structData[item] )#;
</cfloop>
</cfoutput>