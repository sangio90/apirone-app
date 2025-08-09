<cfparam name="action" default="">
<cfparam name="message" default="#StructNew()#">
<cfset path = ExpandPath('/../repository/private/errors/')>

<cfif action IS "delete">
    <cfif !StructIsEmpty( form )>
        <cfset count = 0>
        <cfloop list="#form.ids#" item="item">
            <cfif ListLen( item, '-' ) GT 3>

                <cfset  y = ListFirst(item, '-')>
                <cfset  m = ListGetAt(item, 2, '-')>
                
                <cfif FileExists( "#path#/#y#/#m#/#item#" )>
                    <cfset count++>
                    <cffile action="delete" file="#path#/#y#/#m#/#item#">
                </cfif>
            </cfif>
        </cfloop>
        
        <cfset message = { "type": "success", "text": "I deleted #count# lines." }>

    </cfif>
</cfif>

<cfdirectory action="list" directory="#path#" recurse="true" name="q" sort="name desc">

<cfoutput>

<!doctype html>
<html class="theme-dark">
    <head>
        <title>Errors list</title>
        <meta name=”viewport” content=”width=device-width, initial-scale=1″>
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.0/css/bulma.min.css">
    </head>

    <body>

        <div class="container is-fluid mt-3 mb-3">

            <div class="columns is-gapless">
                <div class="column">
                    <h1 class="title">
                        Errors 500 list
                    </h1>
                </div>
                <div class="column has-text-right">
                    <span class="tag is-success is-hidden" id="message-box"></span>
                </div>

            </div>

            <form action="detail.cfm" target="_blank">
                <div class="field is-horizontal"> 
                    <input name="id" type="text" placeholder="Error ID" class="input mr-2"> <button type="submit" class="button is-primary">Search</button>
                </div>
            </form>

            <div class="mt-5 is-clearfix">
                <div class="is-pulled-right">
                    <button class="button is-primary is-small" onclick="deleteFiles()">Delete</button>
                </div>
            </div>

            <form action="list.cfm?action=delete" method="post" id="list-form">
                <table class="table mt-2 is-striped is-fullwidth">
                    <thead>
                        <tr>
                            <th align="center">##</th>
                            <th>Directory</th>
                            <th>File</th>
                            <th>Size</th>
                            <th>Date</th>
                            <th width="30"><a href="javascript:selectAll()">All</a></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfloop query="q" startRow="1" maxRows="100">
                            <tr>
                                <td align="right"><b>#currentrow#</b>/#recordcount#</td>
                                <td>#directory#</td>
                                <td><a href="detail.cfm?id=#Replace(name, '.html', '')#" target="_blank">#name#</a></td>
                                <td>#size#</td>
                                <td>#DateTimeFormat( dateLastModified, 'dd-mm-yyyy HH:nn:ss')#</td>
                                <td align="center"><input type="checkbox" name="ids" value="#name#"></td>
                            </tr>
                        </cfloop>
                    <tbody>
                </table>
            </form>
        </div>

    </body>

    <script>
        var selectAll = function() {
            var ids = document.getElementsByName("ids");

            for(var i=0; i<ids.length; i++){
                ids[i].checked=true;
            }
        };

        var showMessage = function( type, text ) {
            //type: danger or info

            var ele = document.getElementById('message-box');
            ele.classList.remove( "is-success", "is-danger", "is-hidden" );

            ele.classList.add('is-' + type);

            ele.innerHTML = text;

            //hide message after 5 seconds
            setTimeout(() => {
                ele.classList.add("is-hidden");    
            }, 5000);
                        
        }

        var deleteFiles = function() {
            var ids = document.querySelectorAll('[name="ids"]:checked');

            if ( ids.length > 0 ) {
                //console.log("form", document.getElementById("list-form"))
                document.getElementById("list-form").submit();

            } else {
                showMessage( "danger", "Select at least one row" );
                //alert("Selezionare un record.")
            }

        }

        <cfif Len(message)>
            showMessage( '#message.type#', '#message.text#' );
        </cfif>

    </script>

</html>

</cfoutput>
