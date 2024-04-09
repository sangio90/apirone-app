<cfset svc = new ImageService()>

<cfset start = getTickCOunt()>

<cfset from = ExpandPath('./test-01.jpg')>

<cfset svc.resize( 
    source="#from#",
    destination="#ExpandPath('./test-01-#Left( CreateUUID(), 6)#-ImageMagick.jpg')#",
    newWidth="500" 
)>

<cfset end = getTickCOunt()>

<cfdump var="#(end-start)/1000# sec" label="ImageMagick">

<cfset img = ImageRead( from )>

<cfset from = ExpandPath('./test-01.jpg')>

<cfimage 
    action="resize"
    source="#from#"
    destination="#ExpandPath('./test-01-#Left( CreateUUID(), 6)#-Lucee.jpg')#" 
    overwrite="true"
    width="500">

<cfset end = getTickCOunt()>

<cfdump var="#(end-start)/1000# sec" label="Lucee">
