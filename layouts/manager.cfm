<cfparam name="prc.title" default="">

<cfprocessingdirective suppresswhitespace=true>

<cfoutput>

<!doctype html>
<html  class="fixed sidebar-left-collapsed sidebar-left-with-menu no-overflowscrolling" data-dev="#rc.isDev#">
<head>

    <title><cfif Len( prc.title )>#prc.title# - </cfif> Apir</title>

    <meta charset="utf-8">
    <meta name="author" content="">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />

    <link href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700,800|Shadows+Into+Light" rel="stylesheet" type="text/css">

    <cfmodule template="/apps/utils/ctags/loadAssets.cfm" 
        files="#DESerializeJSON( FileRead( '/config/assets/cssFiles.json.cfm' ) ).manager#"
        destination="/userdata/assets/css"
        type="css">
    
    <script src="/modules/assets/template-admin/vendor/modernizr/modernizr.js"></script>

    <!--- <link rel="stylesheet" href="/assets/#static#/manager/css/kendo-custom.css"> --->
    <link rel="stylesheet" href="/assets/#prc.staticVersion#/manager/css/style.css">

    <script>
        var AP = {};
        AP.config = #SerializeJSON( {} )#;
        AP.message = #SerializeJSON(flash.get("message", {}))#;
    </script>

</head>
<body>
    <section class="body">

        <!-- start: header -->
        <header class="header">
            <div class="logo-container">
                <a href="/manager" class="logo">
                    <img src="/assets/main/img/logo-horizontal.png" width="50%" height="50%" alt="Apir" />
                </a>

                <div class="d-md-none toggle-sidebar-left" data-toggle-class="sidebar-left-opened" data-target="html" data-fire-event="sidebar-left-opened">
                    <i class="fas fa-bars" aria-label="Toggle sidebar"></i>
                </div>

            </div>

            <!-- start: search & user box -->
            <div class="header-right" style="margin-right:30px;">

                <div id="userbox" class="userbox">
                    <a href="##" data-bs-toggle="dropdown">
                        <figure class="profile-picture">
                            <img src="/modules/assets/template-admin/img/!logged-user.jpg" alt="#event.getValue('user').getName()#" class="rounded-circle" 
                                data-lock-picture="/assets/template/img/!logged-user.jpg"
                            >
                        </figure>
                        <div class="profile-info" data-lock-name="John Doe" data-lock-email="#event.getValue('user').getName()#">
                            <span class="name">#event.getValue('user').getName()#</span>
                            <!--- <span class="role">#event.getValue('user').getAccount().getRole().getName()#</span> --->
                        </div>

                        <i class="fa custom-caret"></i>
                    </a>

                    <div class="dropdown-menu" style="width:150px;">
                        <ul class="list-unstyled mb-2">
                            <li class="divider"></li>
                            <li>
                                <a role="menuitem" tabindex="-1" href="/manager/my/profile"><i class="bx bx-user-circle"></i> Il mio profilo</a>
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

                            #renderView('util/menu')#

                            <hr class="separator" />

                        </div>

                    </div>

                </aside>

                <section role="main" class="content-body">

                    <header class="page-header">
                        <h2>&nbsp;</h2>

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

                    <div class="row">
                        <div class="col-lg-12 mb-3">
                            #renderView()#
                        </div>
                    </div>

                </section>


    </section>

    <cfmodule template="/apps/utils/ctags/loadAssets.cfm" 
        files="#DESerializeJSON( FileRead( '/config/assets/jsFiles.json.cfm' ) ).manager#"
        destination="/userdata/assets/js"
        salt="a1"
        type="js">

        <script src="/assets/main/js/vendor/js.cookie.min.js"></script>

        <script src="/assets/#prc.staticVersion#/manager/js/app.js"></script>
        <script src="/assets/#prc.staticVersion#/manager/js/ondomready.js"></script>
        <script src="/assets/#prc.staticVersion#/manager/js/app-widget.js"></script>

        <cfloop array="#prc.jsScripts#" index="script">
            <script src="/assets/#prc.staticVersion#/manager/js/#script#.js"></script>
        </cfloop>

        <iframe src="/manager/live" style="display: none;"></iframe> 
    </body>
</html>
</cfoutput>

</cfprocessingdirective>