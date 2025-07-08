<cfset exception = "a">

<cfdump var="#exception#">
<cfabort>

<cfdump var="#IsEmpty('h')#">
<cfparam name="notExists" default="">

<cfquery datasource="apirone" result="d">
    INSERT INTO _test (
        field1,
        field2
    )
    VALUES (
        <cfqueryparam value="1">,
        <cfqueryparam value="#notExists#" null="#!IsEmpty('notExists')#">
    )
</cfquery>

<!----
<cfquery datasource="apirone" result="d">
    INSERT INTO _test (
        field1,
        field2
    )
    VALUES (
        <cfqueryparam value="1">,
        <cfqueryparam value="#h#" null="#!IsDefined('h')#">
    )
</cfquery>


------>