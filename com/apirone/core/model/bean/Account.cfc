component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	this.memento = {
		defaultIncludes = [ "id", "shortId", "name" ],
		neverIncludes   = [ "pwd", "apiKey" ],
		profiles        = {
			list = {
				defaultIncludes = [
					"id",
					"name",
					"email",
					"phone",
					"serial",
					"status",
					"role",
					"roles",
					"lang"
				]
			}
		}
	}

	property name="email" type="String";
	property name="phone" type="String";
	property name="pwd" type="String";
	property name="apiKey" type="String";
	property name="serial" type="Numeric";
	property name="status" type="com.apirone.core.model.bean.Status";
	property name="role" type="com.apirone.core.model.bean.Role";
	property name="roles" type="com.apirone.core.model.bean.Role[]";
	property name="lang" type="com.apirone.core.model.bean.Lang";

	public Account function init(){
		return this;
	}

}
