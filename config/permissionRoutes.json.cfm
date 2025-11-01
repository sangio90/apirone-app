{
    "MainController.dashboard": { 
        required: ["AUTHENTICATED"]
    },

    "AuthController.*": { 
        required: []
    },

    "AuthController.changeRole": { 
        required: ["AUTHENTICATED"]
    },

    "CurrentUserController.*": { 
        required: ["AUTHENTICATED"]
    },

    "FruitController.*": { 
        required: ["AUTHENTICATED"]
    },

    "FruitAjaxController.*": { 
        required: ["AUTHENTICATED"]
    },

    "AccountController.*": { 
        required: ["AUTHENTICATED"]
    },

    "AccountAjaxController.*": { 
        required: ["AUTHENTICATED"]
    },

}