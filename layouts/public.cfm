<cfset static = rc.isDev ? RandRange(1000, 9999) : 20220521>
<cfparam name="prc.title" default="">

<cfprocessingdirective suppresswhitespace=true>

<cfoutput>

    <!DOCTYPE html>
    <html>
        <head>
    
            <!-- Basic -->
            <meta charset="utf-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">	
    
            <title><cfif Len(prc.title)>#prc.title# |</cfif> Zero Benefit</title>	
    
            <meta name="keywords" content="" />
            <meta name="description" content="">
            <meta name="author" content="Nimesia">
    
            <!-- Favicon -->
            <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
            <link rel="apple-touch-icon" href="/assets/main/img/apple-touch-icon.png">

            <!-- Mobile Metas -->
            <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1.0, shrink-to-fit=no">
    
            <!-- Web Fonts  -->
            <link id="googleFonts" href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700,800%7CRoboto+Slab:300,400,700,900&display=swap" rel="stylesheet" type="text/css">

            <cfmodule template="/apps/utils/ctags/loadAssets.cfm" 
                files="#DESerializeJSON( FileRead( '/config/assets/cssFiles.json.cfm' ) ).public#"
                destination="/userdata/assets/css"
                type="css">
            
            <link rel="stylesheet" href="/assets/public/css/style.css">

            <script src="/modules/assets/template-public/vendor/modernizr/modernizr.min.js"></script>
    
        </head>
        <body>
    
            <div class="body">
                <header id="header" class="header-effect-shrink" data-plugin-options="{'stickyEnabled': true, 'stickyEffect': 'shrink', 'stickyEnableOnBoxed': true, 'stickyEnableOnMobile': false, 'stickyChangeLogo': true, 'stickyStartAt': 30, 'stickyHeaderContainerHeight': 85}">
                    <div class="header-body header-body-bottom-border border-top-0">
                        <div class="header-top header-top-bottom-containered-border pt-2">
                            <div class="container">
                                <div class="header-row">
                                    <div class="header-column justify-content-start">
                                        <div class="header-row">
                                            <ul class="header-social-icons social-icons social-icons-clean social-icons-medium position-relative right-7 d-none d-md-block ms-0">
                                                <!---
                                                <li class="social-icons-whatsapp"><a href="whatsapp:#event.getValue('config').get('offices.registered.phone')#" target="_blank" title="WhatsApp"><i class="fab fa-whatsapp"></i></a></li>
                                                ---->
                                            </ul>
                                        </div>
                                    </div>
                                    <div class="header-column justify-content-end">
                                        <div class="header-row">
                                            <a href="/manager/login" class="custom-header-top-btn-style-1 btn btn-secondary font-weight-bold px-4 px-sm-5 py-3 me-2">AREA RISERVATA &raquo;</a>
                                            <a href="/public/employee/subscribe" class="custom-header-top-btn-style-1 btn btn-secondary font-weight-bold px-4 px-sm-5 py-3">HO UNA GIFCARD &raquo;</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="header-container container">
                            <div class="header-row">
                                <div class="header-column">
                                    <div class="header-row">
                                        <div class="header-logo">
                                            <a href="/">
                                                <img src="/assets/main/img/logo.png" class="img-fluid"  alt="Logo Zero Benefit" width="118" height="70" />
                                            </a>
                                        </div>
                                    </div>
                                </div>
                                <div class="header-column justify-content-end">
                                    <div class="header-row">
                                        <div class="header-nav header-nav-links">
                                            <div class="header-nav-main header-nav-main-text-capitalize header-nav-main-effect-2 header-nav-main-sub-effect-1">
                                                <nav class="collapse">
                                                    <ul class="nav nav-pills" id="mainNav">
                                                        <cfloop array="#getMenu()#" item="item">
                                                            <li><a href="#item.href#" title="#item.title#">#item.title#</a></li>
                                                        </cfloop>
                                                    </ul>
                                                </nav>
                                            </div>
                                        </div>
                                        <button class="btn header-btn-collapse-nav" data-bs-toggle="collapse" data-bs-target=".header-nav-main nav">
                                            <i class="fas fa-bars"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </header>
    
                <div role="main" class="main">

                    #renderView()#
    
                </div>
    
                <footer id="footer" class="bg-color-secondary border-0 mt-0">
                    <div id="footer-sign" style="background: white;" class="pb-5 pt-5">
                        <div class="container container-xl-custom pt-4 pb-3 d-flex align-items-center justify-content-center">
                            <a href="/assets/public/pdf/documento_bando_iti_allegato_marche_poster.pdf" target="_blank">
                                <img src="/assets/public/img/institutional-sign.png" class="img-fluid" style="max-width:380px;">
                            </a>
                        </div>
                    </div>
                    <div class="containter">
                        <div class="row">
                            <div class="col-12 text-center menu-footer pb-5 pt-5">
                                <cfloop array="#getMenu()#" item="item">
                                    <a href="#item.href#">#item.title#</a>
                                </cfloop>
                            </ul>
                        </div>
                        <div class="row pb-5 pt-2">
                            <div class="col-6">
                                <div class="float-end">
                                    <img src="/assets/main/img/logo-white-full.png" width="100">
                                </div>
                            </div>
                            <div class="col-6">
                                <h5>#event.getValue('config').get('owner.name')#</h5>
                                P. Iva: #event.getValue('config').get('owner.vat')#<br>
                                Email: #event.getValue('config').get('owner.email')#
                            </div>
                        </div>

                        <hr>

                        <div class="row">
                            <div class="col-12 text-center pb-4 pt-2">
                                #event.getValue('config').get('owner.name')# &copy; 2022-#Year(now())#. Tutti i diritti riservati.<br>
                                Privacy policy<br>
                                Sviluppato da <a href="https://www.nimesia.com/">Nimesia</a>
                            </div>
                        </div>
                    </div>

                </footer>
            </div>

            <cfmodule template="/apps/utils/ctags/loadAssets.cfm" 
                files="#DESerializeJSON( FileRead( '/config/assets/jsFiles.json.cfm' ) ).public#"
                destination="/userdata/assets/js"
                type="js">

            <script src="/assets/public/js/app.js"></script>
        
        </body>
    </html>
    
</cfoutput>

</cfprocessingdirective>
