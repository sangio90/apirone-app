<!-- filepath: s:\workspace\users\roberto\projects\apir\apps\apirone-app\code\apps\manager\controllers\FrameAjaxController.cfc -->
<cfcomponent extends="coldbox.system.EventHandler" output="false">
    
    <cfproperty name="frameService" inject="model:com.apirone.core.model.service.FrameService">
    
    <cffunction name="list" returntype="void">
        <cfargument name="event">
        <cfargument name="rc">
        <cfargument name="prc">
        
        <cfset var params = {}>
        
        <cfif StructKeyExists(rc, "filter") AND IsStruct(rc.filter)>
            <cfif StructKeyExists(rc.filter, "frame") AND Len(rc.filter.frame)>
                <cfset params.frame = rc.filter.frame>
            </cfif>
            <cfif StructKeyExists(rc.filter, "code") AND Len(rc.filter.code)>
                <cfset params.code = rc.filter.code>
            </cfif>
            <cfif StructKeyExists(rc.filter, "orientationId") AND Len(rc.filter.orientationId)>
                <cfset params.orientationId = rc.filter.orientationId>
            </cfif>
        </cfif>
        
        <cfif StructKeyExists(rc, "sort") AND IsArray(rc.sort) AND ArrayLen(rc.sort) GT 0>
            <cfset var sort = rc.sort[1]>
            <cfset var field = sort.field>
            <cfset var dir = sort.dir>
            <cfset frameService.setSort("#field# #dir#")>
        </cfif>
        
        <cfif StructKeyExists(rc, "page") AND StructKeyExists(rc, "pageSize")>
            <cfset var page = rc.page - 1>
            <cfset var pageSize = rc.pageSize>
            <cfset frameService.setPagination(page * pageSize, pageSize)>
        </cfif>
        
        <cfset var result = frameService.search(params)>
        <cfset var data = []>
        
        <cfloop array="#result.data#" index="item">
            <cfset ArrayAppend(data, getMementify().convert(item, "list"))>
        </cfloop>
        
        <cfset var json = {
            "data" = data,
            "total" = result.total
        }>
        
        <cfset event.renderData(type="JSON", data=json)>
    </cffunction>
    
    <cffunction name="get" returntype="void">
        <cfargument name="event">
        <cfargument name="rc">
        <cfargument name="prc">
        
        <cfset var id = event.getValue("id", "")>
        <cfset var frame = frameService.get(id)>
        
        <cfif IsNull(frame)>
            <cfset event.renderData(type="JSON", data={"success"=false, "message"="Frame non trovato"})>
            <cfreturn>
        </cfif>
        
        <cfset var frameData = getMementify().convert(frame, "detail")>
        <cfset event.renderData(type="JSON", data={"success"=true, "data"=frameData})>
    </cffunction>
    
    <cffunction name="save" returntype="void">
        <cfargument name="event">
        <cfargument name="rc">
        <cfargument name="prc">
        
        <cfset var frameData = event.getHTTPContent(deserializeJSON=true)>
        <cfset var frameId = structKeyExists(frameData, "frameId") ? frameData.frameId : "">
        <cfset var isNew = NOT Len(frameId)>
        <cfset var frame = isNew ? frameService.new() : frameService.get(frameId)>
        
        <cfif isNew>
            <cfif frameService.codeExists(frameData.code)>
                <cfset event.renderData(type="JSON", data={"success"=false, "message"="Il codice è già in uso"})>
                <cfreturn>
            </cfif>
        <cfelse>
            <cfif frameService.codeExists(frameData.code, frameId)>
                <cfset event.renderData(type="JSON", data={"success"=false, "message"="Il codice è già in uso"})>
                <cfreturn>
            </cfif>
        </cfif>
        
        <cfset frame.setFrame(frameData.frame)>
        <cfset frame.setCode(frameData.code)>
        <cfset frame.setOrientationId(frameData.orientationId)>
        <cfset frame.setCellOrientationId(frameData.cellOrientationId)>
        
        <cfif StructKeyExists(frameData, "cells") AND IsArray(frameData.cells)>
            <cfset var cells = []>
            <cfloop array="#frameData.cells#" index="cellData">
                <cfset var cell = createObject("component", "com.apirone.core.model.bean.FrameCell").init()>
                <cfset cell.setRow(cellData.row)>
                <cfset cell.setCol(cellData.col)>
                <cfset cell.setValue(cellData.value)>
                <cfset ArrayAppend(cells, cell)>
            </cfloop>
            <cfset frame.setCells(cells)>
        </cfif>
        
        <cftry>
            <cfset frame = frameService.save(frame)>
            <cfset var data = getMementify().convert(frame, "detail")>
            <cfset event.renderData(type="JSON", data={"success"=true, "data"=data, "message"="Armatura salvata con successo"})>
            <cfcatch>
                <cfset event.renderData(type="JSON", data={"success"=false, "message"="Errore durante il salvataggio: #cfcatch.message#"})>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="delete" returntype="void">
        <cfargument name="event">
        <cfargument name="rc">
        <cfargument name="prc">
        
        <cfset var id = event.getValue("id", "")>
        
        <cftry>
            <cfset frameService.delete(id)>
            <cfset event.renderData(type="JSON", data={"success"=true, "message"="Armatura eliminata con successo"})>
            <cfcatch>
                <cfset event.renderData(type="JSON", data={"success"=false, "message"="Errore durante l'eliminazione: #cfcatch.message#"})>
            </cfcatch>
        </cftry>
    </cffunction>
    
    <cffunction name="codeExists" returntype="void">
        <cfargument name="event">
        <cfargument name="rc">
        <cfargument name="prc">
        
        <cfset var code = event.getValue("code", "")>
        <cfset var excludedId = event.getValue("excludedId", "")>
        <cfset var exists = frameService.codeExists(code, excludedId)>
        
        <cfset event.renderData(type="JSON", data={"exists"=exists})>
    </cffunction>
    
</cfcomponent>