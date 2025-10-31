<cfset service = getInstance( "MenuService" )>

<cfset menu = service.getMenuStructure()>

<cfoutput>
    <nav id="menu" class="nav-main" role="navigation">
        <ul class="nav nav-main">
            #createMenu( menu, "/manager#prc.currentRouteName#" )#
        </ul>
    </nav>
</cfoutput>