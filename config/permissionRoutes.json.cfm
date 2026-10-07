{
    "DEFAULT_POLICY": { 
        "required": ["AUTHENTICATED"] 
    },

    "AuthController.*": { 
        required: []
    },

    "LineController.*": {
        "roles": ["ADM", "CMS"],
    },

    "ErrorLogController.*": {
        "roles": ["ADM"],
    },

}