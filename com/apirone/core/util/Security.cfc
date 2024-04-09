component output="false" accessors="true" {
	
	property name="key" type="String";
	property name="algorithm" type="String";
	property name="algorithmEncoding" type="String";

	public String function encryptString( required String value ){

		return encrypt( arguments.value, createKey(), getAlgorithm(), getAlgorithmEncoding() );
	
	}
	
	public String function decryptString( required String value ){
		
		return decrypt( arguments.value, createKey(), getAlgorithm(), getAlgorithmEncoding() );
	
	}

	public String function createKey(){
		
		return Hash( "ciJAJYy*&+e12ao" & getKey() );
	
	}

}
