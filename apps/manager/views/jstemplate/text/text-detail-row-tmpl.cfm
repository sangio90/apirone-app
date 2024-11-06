<cfprocessingdirective pageEncoding='UTF-8'>

<cfoutput>
    <nmscript type="text/x-kendo-template" id="text-detail-row-tmpl">

        <div class="row mb-3">

            <div class="divider mb-3"><span data-bind="text: lang.name"></span></div>

            <label class="col-sm-2 text-end mt-2" data-bind="text: lang.name">Traduzione</label>
            <div class="col-sm-10 mb-3">
                <input type="text" class="form-control" 
                    required
                    data-bind="value: name">
            </div>

            <label class="col-sm-2 text-end mt-2">Status</label>
            <div class="col-sm-10 mb-3">
                <select class="form-control" data-bind="value: status.id">
                    <cfloop array="#prc.statusList#" item="item">
                        <option value="#item.getId()#">#item.getName()#</option>
                    </cfloop>
                </select>
            </div>

        </div>
        
    </nmscript>
</cfoutput>