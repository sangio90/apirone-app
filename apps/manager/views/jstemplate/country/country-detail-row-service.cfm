<cfoutput>
    <nmscript type="text/x-kendo-template" id="country-detail-row-service-tmpl">

        <div style="float: left; width: 110px;">
            <span class="checkbox-custom chekbox-primary me-4" >
                <input id="country_serviceType_##:uid##" value="true" 
                    type="checkbox" 
                    name="serviceType"
                    data-bind="checked: detailForm.data.serviceTypesSelected, value: id"
                >
                <label for="country_serviceType_##:uid##" data-bind="text:serviceType.name"></label>
            </span>
            
            <input type="text" 
                placeholder="Giorni"
                class="form-control mt-2" 
                id="country_days_##:uid##" 
                data-bind="value: days"
                style="width: 90px"
            >
        </div>
    
    </nmscript>
</cfoutput>

