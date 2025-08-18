<cfdirectory action="list" directory="#ExpandPath('/../repository/private/errors')#" recurse="true" name="fileList" sort="name desc">

<cfdump var="#fileList#">



<cfset test = queryNew("name,age","varchar,numeric",{name:["Susi","Urs","john","jerry"],age:[20,20,28,32]})>
<cfoutput query="test" maxrows="3">
	#name#
	#age#
</cfoutput>