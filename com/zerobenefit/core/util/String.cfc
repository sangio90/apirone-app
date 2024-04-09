component {
    
    public String function createRandomCode(
        required Numeric numChars = 5,
        required String startWith = ""
    ){


        var chars = "abcdefghijklmnopqrstuvwxyz1234567890";
        
        var random = CreateObject("java", "java.util.Random").init();
        
        var result = CreateObject("java", "java.lang.StringBuffer").init(javaCast("int", arguments.numChars));
        var index = 0;
        
        for ( index=1 ; index<=arguments.numChars ; index++ ) {
            
            result.append(
                chars.charAt(
                    random.nextInt( chars.length() )
                )
            );
        
        }

        return arguments.startWith & result.toString();
    
    }

}