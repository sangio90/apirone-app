<cfparam name="prc.title" default="">
<cfparam name="prc.subtitle" default="">

<cfprocessingdirective suppresswhitespace=true>

<cfoutput>

<!doctype html>
<html  class="fixed sidebar-left-collapsed sidebar-left-with-menu no-overflowscrolling" data-dev="#prc.isDev#">
<head>

    <title><cfif prc.isDev>*</cfif><cfif Len( prc.title )>#prc.title# - </cfif><cfif Len( prc.subtitle )>#prc.subtitle# - </cfif> ApirOne</title>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />

    <!---
    <link href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700,800|Shadows+Into+Light" rel="stylesheet" type="text/css">
    ---->
    <link href="/assets/main/css/fonts.css" rel="stylesheet" type="text/css">

    <cfmodule template="/apps/utils/ctags/loadAssets.cfm" 
        files="#DESerializeJSON( FileRead( '/config/assets/cssFiles.json.cfm' ) ).manager#"
        destination="/userdata/assets/css"
        type="css">
    
    <script src="/modules/assets/template-admin/vendor/modernizr/modernizr.js"></script>
    <script src="/modules/assets/template-admin/vendor/jquery/jquery.js"></script>

    <link rel="stylesheet" href="/assets/#prc.staticVersion#/manager/css/style.css">
    <link rel="stylesheet" href="/assets/main/#prc.staticVersion#/css/kendo-custom.css">
    <link rel="stylesheet" href="/assets/main/#prc.staticVersion#/css/colors.css">

    <script>
        //TODO: use AP.page for current page and AP.config for global
        var AP = {};
        AP.fields = {};
        AP.config = #SerializeJSON( prc.config )#;
        AP.page = #SerializeJSON( prc.page )#;
        AP.message = #SerializeJSON(flash.get("message", {}))#;
    </script>

</head>
<body>
    <section class="body">

        <header class="header">
            <div class="logo-container">
                <a href="/manager/dashboard" class="logo">
                    <img src="/assets/main/img/logo.png" width="50%" height="50%" alt="Apir" />
                </a>

                <div class="d-md-none toggle-sidebar-left" data-toggle-class="sidebar-left-opened" data-target="html" data-fire-event="sidebar-left-opened">
                    <i class="fas fa-bars" aria-label="Toggle sidebar"></i>
                </div>

            </div>

            <div class="header-right" style="margin-right:30px;">

                <div id="userbox" class="userbox">
                    <a href="##" data-bs-toggle="dropdown">
                        <figure class="profile-picture">
                            <img src="/modules/assets/template-admin/img/!logged-user.jpg" alt="#prc.user.getName()#" class="rounded-circle" 
                                data-lock-picture="/assets/template/img/!logged-user.jpg"
                            >
                        </figure>
                        <div class="profile-info" data-lock-name="#prc.user.getName()#" data-lock-email="#prc.user.getName()#">
                            <span class="name">
                                #prc.user.getName()#<br>
                            </span>
                            <span class="role">
                                #prc.user.getRole().getId()# - #prc.user.getShortId()#
                            </span>
                        </div>

                        <i class="fa custom-caret"></i>
                    </a>

                    <div class="dropdown-menu" style="width:150px;">
                        <ul class="list-unstyled mb-2">
                            <li class="divider"></li>
                            <li>
                                <a role="menuitem" tabindex="-1" href="/manager/my/account"><i class="bx bx-user-circle"></i> Il mio profilo</a>
                            </li>
                            <li>
                                <a role="menuitem" tabindex="-1" href="/manager/logout"><i class="bx bx-power-off"></i> Esci</a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
            <!-- end: search & user box -->
        </header>
        <!-- end: header -->

        <div class="inner-wrapper">
            <!-- start: sidebar -->
            <aside id="sidebar-left" class="sidebar-left">

                <div class="sidebar-header">
                    <div class="sidebar-title">
                        Menù
                    </div>
                    <div class="sidebar-toggle d-none d-md-block" 
                        id="sidebar-button"
                        data-toggle-class="sidebar-left-collapsed" 
                        data-target="html" 
                        data-fire-event="sidebar-left-toggle">
                            <i class="fas fa-bars" aria-label="Toggle sidebar"></i>
                    </div>
                </div>

                <div class="nano">
                    <div class="nano-content" style="right: -17px;">

                        #view('util/menu')#

                        <hr class="separator" />

                    </div>

                </div>

            </aside>

            <section role="main" class="content-body">

                <header class="page-header">

                    <div class="right-wrapper text-end">
                        <ol class="breadcrumbs">
                            <li>
                                <a href="/manager/dashboard">
                                    <i class="bx bx-home-alt"></i>
                                </a>
                            </li>

                            #breadcrumbs( '/manager#prc.currentRouteName#' )#

                        </ol>

                    </div>
                </header>

                <div class="row" id="page-content">
                    <div class="col-lg-12 mb-3">
                        #view()#
                    </div>
                    <div class="col-lg-12 mb-3">
                        <div>#event.getCurrentEvent()# > #event.getCurrentView()#</div>
                    </div>
                </div>
            </section>

    </section>

    <cfmodule template="/apps/utils/ctags/loadAssets.cfm" 
        files="#DESerializeJSON( FileRead( '/config/assets/jsFiles.json.cfm' ) ).manager#"
        destination="/userdata/assets/js"
        salt="a1"
        type="js">

        <script src="/assets/main/js/nimesia-kendo.js"></script>
        <script src="/assets/#prc.staticVersion#/main/js/nimesia-util.js"></script>

        <script src="/assets/#prc.staticVersion#/manager/js/app.js"></script>
        <script src="/assets/#prc.staticVersion#/manager/js/ondomready.js"></script>
        <script src="/assets/#prc.staticVersion#/manager/js/app-util.js"></script>
        <script src="/assets/#prc.staticVersion#/manager/js/app-widget.js"></script>

        #includeJsFiles()#

        <cfif prc.isDev>
            <style>.header{ border-top: 3px solid Red !important }</style>
        </cfif>

        <iframe src="/manager/live" style="display:none;"></iframe> 

    </body>
</html>
</cfoutput>

</cfprocessingdirective>