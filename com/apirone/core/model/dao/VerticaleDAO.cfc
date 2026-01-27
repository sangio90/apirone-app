<cfcomponent accessors="true" extends="com.apirone.core.model.dao.AbsDAO">

     <cfset variables.companyId = "azapi">

    <cffunction name="listMockedCurrency" access="public" returntype="Query" output="false">
        <cfset var records = listMockedRawCurrency()>
        <cfset var q = QueryNew( "currency_id,currency,simbol,total", "Integer,Varchar,Varchar,Integer" )>
        
        <cfloop array="#records#" index="record">
            <cfset QueryAddRow( q )>
            <cfset QuerySetCell( q, "currency_id", record.currency_id )>
            <cfset QuerySetCell( q, "currency", record.currency )>
            <cfset QuerySetCell( q, "simbol", record.simbol )>
            <cfset QuerySetCell( q, "total", records.len() )>
        </cfloop>
        
        <cfreturn q>
    </cffunction>

    <!--- 
        mocked data retrieval
    --->

    <cffunction name="getMockedCurrency" access="public" returntype="Query" output="false">
        <cfargument name="currencyId" type="String" required="true">
        
        <cfset var records = listMockedRawCurrency()>
        <cfset var q = QueryNew( "currency_id,currency,simbol,total", "Integer,Varchar,Varchar,Integer" )>
        
        <cfloop array="#records#" index="record">
            <cfif record.currency_id EQ arguments.currencyId>
                <cfset QueryAddRow( q )>
                <cfset QuerySetCell( q, "currency_id", record.currency_id )>
                <cfset QuerySetCell( q, "currency", record.currency )>
                <cfset QuerySetCell( q, "simbol", record.simbol )>
                <cfset QuerySetCell( q, "total", records.len() )>
                <cfbreak>
            </cfif>
        </cfloop>
        
        <cfreturn q>
    </cffunction>

    <cffunction name="listMockedVatCode" access="public" returntype="Query" output="false">
        <cfset var records = listMockedRawVatCode()>
        <cfset var q = QueryNew( "ivacod,ivades,ivaper,total", "Integer,Varchar,Decimal,Integer" )>
        
        <cfloop array="#records#" index="record">
            <cfset QueryAddRow( q )>
            <cfset QuerySetCell( q, "ivacod", record.ivacod )>
            <cfset QuerySetCell( q, "ivades", record.ivades )>
            <cfset QuerySetCell( q, "ivaper", record.ivaper )>
            <cfset QuerySetCell( q, "total", records.len() )>
        </cfloop>
        
        <cfreturn q>
    </cffunction>

    <cffunction name="getMockedVatCode" access="public" returntype="Query" output="false">
        <cfargument name="vatCodeId" type="String" required="true">
        
        <cfset var records = listMockedRawVatCode()>
        <cfset var q = QueryNew( "ivacod,ivades,ivaper,total", "Integer,Varchar,Decimal,Integer" )>
        
        <cfloop array="#records#" index="record">
            <cfif record.ivacod EQ arguments.vatCodeId>
                <cfset QueryAddRow( q )>
                <cfset QuerySetCell( q, "ivacod", record.ivacod )>
                <cfset QuerySetCell( q, "ivades", record.ivades )>
                <cfset QuerySetCell( q, "ivaper", record.ivaper )>
                <cfset QuerySetCell( q, "total", records.len() )>
                <cfbreak>
            </cfif>
        </cfloop>
        
        <cfreturn q>
    </cffunction>

    <cffunction name="listMockedPaymentMethod" access="public" returntype="Query" output="false">
        <cfset var records = listMockedRawPaymentMethod()>
        <cfset var q = QueryNew( "payment_method_id,payment_method,total", "Integer,Varchar,Integer" )>
        
        <cfloop array="#records#" index="record">
            <cfset QueryAddRow( q )>
            <cfset QuerySetCell( q, "payment_method_id", record.payment_method_id )>
            <cfset QuerySetCell( q, "payment_method", record.payment_method )>
            <cfset QuerySetCell( q, "total", records.len() )>
        </cfloop>
        
        <cfreturn q>
    </cffunction>

    <cffunction name="getMockedPaymentMethod" access="public" returntype="Query" output="false">
        <cfargument name="paymentMethodId" type="String" required="true">
        
        <cfset var records = listMockedRawPaymentMethod()>
        <cfset var q = QueryNew( "payment_method_id,payment_method,total", "Integer,Varchar,Integer" )>
        
        <cfloop array="#records#" index="record">
            <cfif record.payment_method_id EQ arguments.paymentMethodId>
                <cfset QueryAddRow( q )>
                <cfset QuerySetCell( q, "payment_method_id", record.payment_method_id )>
                <cfset QuerySetCell( q, "payment_method", record.payment_method )>
                <cfset QuerySetCell( q, "total", records.len() )>
                <cfbreak>
            </cfif>
        </cfloop>
        
        <cfreturn q>
    </cffunction>

    <cffunction name="listMockedCountry" access="public" returntype="Query" output="false">
        <cfset var records = listMockedRawCountry()>
        <cfset var q = QueryNew( "ISONAZ,CODNAZ,DESNAZ,total", "Varchar,Varchar,Varchar,Integer" )>
        
        <cfloop array="#records#" index="record">
            <cfset QueryAddRow( q )>
            <cfset QuerySetCell( q, "ISONAZ", record.ISONAZ )>
            <cfset QuerySetCell( q, "CODNAZ", record.CODNAZ )>
            <cfset QuerySetCell( q, "DESNAZ", record.DESNAZ )>
            <cfset QuerySetCell( q, "total", records.len() )>
        </cfloop>
        
        <cfreturn q>
    </cffunction>

    <cffunction name="getMockedCountry" access="public" returntype="Query" output="false">
        <cfargument name="countryId" type="String" required="true">
        
        <cfset var records = listMockedRawCountry()>
        <cfset var q = QueryNew( "ISONAZ,CODNAZ,DESNAZ,total", "Varchar,Varchar,Varchar,Integer" )>
        
        <cfloop array="#records#" index="record">
            <cfif record.ISONAZ EQ arguments.countryId>
                <cfset QueryAddRow( q )>
                <cfset QuerySetCell( q, "ISONAZ", record.ISONAZ )>
                <cfset QuerySetCell( q, "CODNAZ", record.CODNAZ )>
                <cfset QuerySetCell( q, "DESNAZ", record.DESNAZ )>
                <cfset QuerySetCell( q, "total", records.len() )>
                <cfbreak>
            </cfif>
        </cfloop>
        
        <cfreturn q>
    </cffunction>

    <!---
        private methods
    --->

    <cffunction name="listMockedRawVatCode" access="private" returntype="Array" output="false">
        <cfreturn [
            { ivacod="4", ivades="IVA 4%", ivaper="4.00" },
            { ivacod="7", ivades="IVA 7%", ivaper="7.00" },
            { ivacod="10", ivades="IVA 10%", ivaper="10.00" },
            { ivacod="22", ivades="IVA 22%", ivaper="22.00" },
            { ivacod="106", ivades="MNF 17% TRASPORTI PER RSM", ivaper="17.00" },
            { ivacod="203", ivades="ESENTE RSM IVA 0%", ivaper="0.00" }
        ]>
    </cffunction>

    <cffunction name="listMockedRawCurrency" access="private" returntype="Array" output="false">
        <cfreturn [
            { currency_id="1", currency="Euro", simbol="€" },
            { currency_id="2", currency="US Dollar", simbol="$" },
            { currency_id="3", currency="British Pound", simbol="£" },
            { currency_id="4", currency="Japanese Yen", simbol="¥" }
        ]>
    </cffunction>

    <cffunction name="listMockedRawPaymentMethod" access="private" returntype="Array" output="false">
        <cfreturn [
            { payment_method_id="1", payment_method="Contanti" },
            { payment_method_id="18", payment_method="Bonifico Bancario" },
            { payment_method_id="3", payment_method="Carta di Credito" },
            { payment_method_id="4", payment_method="PayPal" },
            { payment_method_id="5", payment_method="Assegno" }
        ]>
    </cffunction>

    <cffunction name="listMockedRawCountry" access="private" returntype="Array" output="false">
        <cfreturn [
            { ISONAZ="IT", CODNAZ="380", DESNAZ="Italia" },
            { ISONAZ="US", CODNAZ="840", DESNAZ="Stati Uniti" },
            { ISONAZ="GB", CODNAZ="826", DESNAZ="Regno Unito" },
            { ISONAZ="DE", CODNAZ="276", DESNAZ="Germania" },
            { ISONAZ="FR", CODNAZ="250", DESNAZ="Francia" }
        ]>
    </cffunction>

</cfcomponent>