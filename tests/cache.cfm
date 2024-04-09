<cfset cm = server.wirebox.getInstance( "CacheManager" )>

<!---
<cfset cm.removeAll()>
---->

<cfdump var="#cm.list()#">
