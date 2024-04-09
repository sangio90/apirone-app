<cfoutput>
ZB.data = {};
ZB.data.countriesByArea = #SerializeJSON( rc.countries )#;
ZB.data.texts = #SerializeJSON( rc.texts )#;
</cfoutput>