{
    "DEFAULT_POLICY": { 
        "required": ["AUTHENTICATED"] 
    },

    "AuthController.*": { 
        required: []
    },

    "LineController.*": { 
        "roles": ["ADM"],
    },

}