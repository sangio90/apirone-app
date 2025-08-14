<cfoutput>

    <div id="line-products-root">

        <div class="row">
            <div class="col-8">
                #pageTitle()#
            </div>
            <div class="col-4 text-end pt-2">
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

                            <table class="table table-hover table-header-fixed">
                                <thead>
                                <tr>
                                    <th></th>
                                    <cfloop array="#prc.models#" item="model">
                                        <th>
											#model.getCode()#
                                            <br>
                                            <br>
											<cfif NOT IsNull(model.getType()) && model.getType().getId() EQ "S">
												<cfif NOT isNull(model.modelConfig)>
													<button class="btn btn-primary btn-xs" data-bind="click:showModelConfigModal"
														data-product-category-id="#prc.category.getId()#"
														data-line-id="#prc.line.getId()#"
														data-model-id="#model.getId()#"
														data-model-config-id="#model.modelConfig.getId()#"
														data-width="#model.modelConfig.getWidth()#"
														data-height="#model.modelConfig.getheight()#"
													>
														<i class="fa fa-ruler"></i>
													</button>
													<div style="font-model: .6em; font-style: italic; color: gray;">
														#model.modelConfig.getWidth()# x #model.modelConfig.getHeight()#
													</div>
												<cfelse>
													<button class="btn btn-default btn-xs" data-bind="click:showModelConfigModal"
														data-product-category-id="#prc.category.getId()#"
														data-line-id="#prc.line.getId()#"
														data-model-id="#model.getId()#"
													>
													<i class="fa fa-ruler"></i>
													</button>
													<div style="height: 1.4em;">&nbsp;</div>
												</cfif>
											</cfif>
										</th>
                                    </cfloop>
                                </tr>
                                </thead>
                                <tbody>
                                <cfloop array="#prc.finishes#" item="finish">
                                    <tr class="no-highlight">
                                        <td class="no-highlight">
                                            #finish.getName()# <span class="small-code">(#finish.getShortId()#)</span>
                                        </td>
                                        <cfloop array="#prc.models#" item="model">
                                            <td>

                                                <cfset exists = productExists( model.getId(), finish.getId() )>

                                                <button class="btn btn-success btn-sm active" data-bind="click:deactivate"
                                                    data-category="#prc.category.getId()#"
                                                    data-values="#model.getId()#__#finish.getId()#"
                                                    <cfif !exists>style="display: none"</cfif>
                                                    >
                                                    <i class="fa fa-minus"></i>
                                                </button>

                                                <button class="btn btn-primary btn-sm deactive" data-bind="click:activate"
                                                data-category="#prc.category.getId()#"
                                                    data-values="#model.getId()#__#finish.getId()#"
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
		#view( "line/model-config-modal" )#
    </div>

</cfoutput>