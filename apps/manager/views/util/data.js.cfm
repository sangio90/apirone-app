<cfoutput>
ZB.data = {};

ZB.config = {}
ZB.config.regexp = {};
ZB.config.regexp.pwd = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(.*){8,}$/;

<cfloop collection="#prc.structData#" item="item">
    ZB.data['#item#'] = #SerializeJSON( prc.structData[item] )#;
</cfloop>
</cfoutput>