<cfoutput>

    <div id="line-products-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
            <div class="col-4 text-end">
                #button( label="Attributi e valori &raquo;", bind="click:attributes", size="sm" )#
            </div>
        </div>

        <div class="row">

            <div class="col-lg-12">

                <section class="card">

                    <div class="card-body">

                        <div class="mt-1 mb-3 row">
                            <div class="col-9">
                                <span class="red">Non tutte le combinazioni possono essere rimosse se sono state movimentate.</span>
                            </div>
                            <div id="line-products-status" class="col-3 text-end h-20"></div>
                        </div>

                        <form name="line-products-form" id="line-products-form" method="post">

                            <table class="table table-hover">
                                <thead>
                                <tr>
                                    <th></th>
                                    <cfloop array="#prc.sizes#" item="size">
                                        <th>
											#size.getCode()#
												<br>
												<br>
											<cfif NOT isNull(size.sizeConfig)>
												<button class="btn btn-primary btn-xs" data-bind="click:showSizeConfigModal"
													data-product-category-id="#prc.category.getId()#"
													data-line-id="#prc.line.getId()#"
													data-size-id="#size.getId()#"
													data-size-config-id="#size.sizeConfig.getId()#"
													data-width="#size.sizeConfig.getWidth()#"
													data-height="#size.sizeConfig.getheight()#"
												>
													<i class="fa fa-ruler"></i>
												</button>
												<div style="font-size: .6em; font-style: italic; color: gray;">
													#size.sizeConfig.getWidth()# x #size.sizeConfig.getHeight()#
												</div>
											<cfelse>
												<button class="btn btn-default btn-xs" data-bind="click:showSizeConfigModal"
													data-product-category-id="#prc.category.getId()#"
													data-line-id="#prc.line.getId()#"
													data-size-id="#size.getId()#"
												>
												<i class="fa fa-ruler"></i>
												</button>
												<div style="height: 1.4em;">&nbsp;</div>
											</cfif>
										</th>
                                    </cfloop>
                                </tr>
                                </thead>
                                <tbody>
                                <cfloop array="#prc.finishes#" item="finish">
                                    <cfset  finishName = finish.getMainText().getName()>
                                    <tr>
                                        <td>
                                            #finish.getMainText().getName()# <span class="small-code">(#finish.getShortId()#)</span>
                                        </td>
                                        <cfloop array="#prc.sizes#" item="size">
                                            <td>

                                                <cfset exists = productExists( size.getId(), finish.getId() )>

                                                <button class="btn btn-danger btn-sm active" data-bind="click:deactivate"
                                                    data-category="#prc.category.getId()#"
                                                    data-values="#size.getId()#__#finish.getId()#"
                                                    <cfif !exists>style="display: none"</cfif>
                                                    >
                                                    <i class="fa fa-minus"></i>
                                                </button>

                                                <button class="btn btn-primary btn-sm deactive" data-bind="click:activate"
                                                data-category="#prc.category.getId()#"
                                                    data-values="#size.getId()#__#finish.getId()#"
                                                    <cfif exists>style="display: none"</cfif>
                                                    >
                                                    <i class="fa fa-plus"></i>
                                                </button>

                                            </td>

                                        </cfloop>
                                    </tr>
                                </cfloop>
                                </tbody>
                            </table>

                        </form>

                    </div>
                </section>
            </div>
        </div>
		#view( "line/size-config-modal" )#
    </div>

</cfoutput>