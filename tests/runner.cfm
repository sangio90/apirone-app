<cfsetting showdebugoutput="false">
<cfparam name="url.reporter" default="simple"> <!--- simple --->
<cfparam name="url.directory" default="tests.specs.com.Apir">
<cfparam name="url.recurse"	default="true" type="boolean">
<cfparam name="url.bundles"	default="">
<cfparam name="url.labels" 	default="">
<cfparam name="url.reportpath" default="#ExpandPath( "/test/results" )#">
<cfparam name="url.propertiesFilename" default="TEST.properties">
<cfparam name="url.propertiesSummary" default="false" type="boolean">

<cfinclude template="/testbox/system/runners/HTMLRunner.cfm" >