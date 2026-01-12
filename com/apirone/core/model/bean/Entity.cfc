component extends="com.apirone.core.model.bean.AbsBean" accessors="true" {

	property name="key";
	property name="value";

	public com.apirone.core.model.bean.Entity function init(){
		return this;
	}

	public Struct function getMemento(){
		var obj = new com.apirone.core.model.bean.AbsBean()

		return obj.getRawMemento( this );
	}

	public Struct function setMemento( data ){
		var obj = new com.apirone.core.model.bean.AbsBean()

		return obj.setRawMemento( data, GetMetadata( this ) );
	}

	public String function getShortValue(){
		return Right( this.getValue(), 6 );
	}

}
