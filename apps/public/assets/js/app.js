$.validator.addMethod( "loginRule", function( value, element ) {
    var re = SITE.config.regexp.login;
    return this.optional( element ) || re.test( value );
}, "Letters, numbers, hyphen, underscore and dot." );

$.validator.addMethod( "pwdRule", function( value, element ) {
    var re = SITE.config.regexp.pwd;
    return this.optional( element ) || re.test( value );
}, "At least one char uppercase, one char lowercase, at least one number." );

$.validator.addMethod( "checkSum", function( value, element ) {

    var add1 = parseFloat( $('#addendum1').val() );
    var add2 = parseFloat( $('#addendum2').val() );
    var result = parseFloat( $('#sum-result').val() );

    if ( add1 + add2 == result ) {
        return true;
    }

    return false;
}, "Incorrect sum result" );


$('#fiscalCodeForm').validate( {
    onfocusout: function( element ) {
        $(element).valid();
    },
    rules: {
        contactPerson: {
            required: true,
        },
    },
    messages: {
        contactPerson: {
            required: "Referente richiesto",
        },
    },

} );