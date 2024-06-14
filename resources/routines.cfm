<cfset wirebox = server['wireBox-apirone']>
<cfset cm = wirebox.getInstance( "CacheManager" )>

<cfoutput>
<title>Routines</title>
	
<cfparam name="action" default="">

<h1>Routine <a href="?">Restart</a></h1>
<div class="info">
	<b>Sistema</b>: Lucee #server.lucee.version#<br>
	<b>Locale</b>: #GetLocaleInfo().name#<br>
	<b>Memoria</b>: #(GetSystemTotalMemory()-GetSystemFreeMemory())/1000000# MB di #GetSystemTotalMemory()/1000000# MB totali
</div>

<div class="button">
	<a href="?action=cache.empty">Svuota cache</a>
	<a href="?action=cache.list">Lista cache</a>
	<a href="?action=info.read">Info</a>
	<a href="?action=docs.create">Crea docs</a>
</div>

<cfif action IS "cache.list">

	<cfset list = cm.list()>
	
	<p>Hai [#list.len()#] chiavi.</p>

	<!--- list keys --->
	<cfloop collection="#list#" item="key">
		<cfdump var="#key#">
	</cfloop>

</cfif>

<cfif action IS "info.read">

	<cfset list = cm.list()>
	<cfset count = cm.list().len()>
	<cfset size = 0>

	<cfset total= 0>

	<cfloop collection="#list#" item="key">
		<cfset size = CacheGetMetadata( key ).size>
		<cfset total = total = size>
	</cfloop>
	
	<p>
		Dimensione della cache: <b>#total/1000# kB</b> su <b>#count#</b> oggetti<br>
		Dimensione del model: <b>#SizeOf( wirebox )/1000# kB</b><br>
	</p>

</cfif>

<cfif action IS "cache.empty">

	<cfset count = cm.list().len()>

	<cfset cm.removeAll()>

	<p>Rimosse [#count#] chiavi.</p>
</cfif>

<cfif action IS "docs.create">

	<cfset path = "#ExpandPath( '/' )#../repository/private/docs">
	
	<cfif( DirectoryExists( path ) )>
		<cfset DirectoryDelete( path, true )>
	</cfif>

	<cfset docbox = new docbox.DocBox( properties = { 
	    projectTitle = "OpusPlus Docs",
	    outputDir    = path
	})>

	<cfset docbox.generate(  
		source  = ExpandPath( "/com/opusplus/core/" ),
		mapping = "com.opusplus.core"
	)>

	<p>Fatto</p>

</cfif>

</cfoutput>

<style>
	body {
		padding: 20px;
		font-family: "Verdana"
	}

	h1 { 
		font-family: 'Georgia', sans-serif; 
		font-size: 45px; 
		line-height: 48px; 
		margin-bottom: 10px;
	}

	h1 a {
		text-decoration: underline;
		font-family: "Verdana";
		font-size: 12px;
		color: black;
	}

	.button a {
		margin-right: 10px;
		background-color: red;
	  	box-shadow: 0 5px 0 darkred;
	  	color: white;
	  	padding: 0.7em 1.2em;
	  	position: relative;
	  	text-decoration: none;
	  	text-transform: uppercase;
	}

	.button a:hover {
	 	background-color: #ce0606;
	  	cursor: pointer;
	}

	.button a:active {
	 	box-shadow: none;
	  	top: 5px;
	}

	.button { padding-bottom: 20px; }

	.info {
		font-size: 11px;
		margin-bottom: 10px;
		padding-bottom: 25px;
	}

</style>