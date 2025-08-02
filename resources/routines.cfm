<cfset wirebox = server['wireBox-apirone']>
<cfset cm = wirebox.getInstance( "CacheManager" )>
<cfparam name="action" default="">

<cfoutput>

<html class="theme-dark">
<head>
	<title>ApirOne - Routines</title>
	<meta name=”viewport” content=”width=device-width, initial-scale=1″>
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.0/css/bulma.min.css">
	<style>
		h1 a { text-decoration: underline; font-size: 12px; }
	</style>
</head>
	
<body>

	<div class="container is-fluid mt-3 mb-3">	

		<h1 class="title">Routines 
			<a href="?fwreinit=1">FwReinit</a>
		</h1>
		
		<div class="columns">
			<div class="column">
				<b>Sistema</b>: Lucee #server.lucee.version#<br>
				<b>Locale</b>: #GetLocaleInfo().name#<br>
			</div>
		</div>

		<div class="columns is-gapless">
			<a href="?action=cache.empty" class="button is-primary mr-2">Svuota cache</a>
			<a href="?action=cache.list" class="button is-primary mr-2">Lista cache</a>
			<a href="/resources/errors/list.cfm" class="button is-primary mr-2">Errori</a>
			<a href="?action=info.read" class="button is-primary mr-2">Info</a>
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

		<cfdump var="#GetApplicationMetadata().datasources#">
		
	</div>

</body>
</html>

</cfoutput>
