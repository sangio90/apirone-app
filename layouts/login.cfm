<cfprocessingdirective suppresswhitespace=true>

<cfoutput>

    <!doctype html>
    <html class="fixed">
        <head>

            <title>Login - ApirOne</title>

            <meta charset="UTF-8">
            <meta name="author" content="Nimesia snc">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />

            <link href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700,800|Shadows+Into+Light" rel="stylesheet" type="text/css">

            <cfmodule template="/apps/utils/ctags/loadAssets.cfm" 
                files="#DESerializeJSON( FileRead( '/config/assets/cssFiles.json.cfm' ) ).login#"
                destination="/userdata/assets/css"
                salt="login-a1"
                type="css">

            <link href="/assets/#prc.staticVersion#/manager/css/style-login.css" rel="stylesheet" type="text/css">

            <script>
                var AP = {}
            </script>

        </head>
        <body>

            <section class="body-sign">
                #renderView()#
            </section>

            <cfmodule template="/apps/utils/ctags/loadAssets.cfm" 
                files="#DESerializeJSON( FileRead( '/config/assets/jsFiles.json.cfm' ) ).login#"
                destination="/userdata/assets/js"
                salt="login-a1"
                type="js">

                <script src="/assets/#prc.staticVersion#/manager/js/app.js"></script>
                <script src="/assets/#prc.staticVersion#/manager/js/ondomready.js"></script>
                <script src="/assets/#prc.staticVersion#/manager/js/app-login.js"></script>

        </body>
    </html>

</cfoutput>

</cfprocessingdirective>