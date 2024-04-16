{

    login: [
        { file: "/modules/assets/template-admin/vendor/bootstrap/css/bootstrap.css" },
        { file: "/modules/assets/template-admin/vendor/animate/animate.compat.css" },
        { 
            file: "/modules/assets/template-admin/vendor/font-awesome/css/all.min.css",
            replacements: [
                {
                    find: "../webfonts/fa-brands-400.",
                    replace: "/modules/assets/template-admin/vendor/font-awesome/webfonts/fa-brands-400."
                },
                {
                    find: "../webfonts/fa-solid-900.",
                    replace: "/modules/assets/template-admin/vendor/font-awesome/webfonts/fa-solid-900."
                },
                {
                    find: "../webfonts/fa-regular-400.", 
                    replace: "/modules/assets/template-admin/vendor/font-awesome/webfonts/fa-regular-400."
                },
            ]
        },
        { 
            file: "/modules/assets/template-admin/vendor/boxicons/css/boxicons.min.css",
            replacements:[
                {
                    find:"../fonts/boxicons.",
                    replace:"/modules/assets/template-admin/vendor/boxicons/fonts/boxicons."
                }
            ]
        },
        { file: "/modules/assets/template-admin/vendor/magnific-popup/magnific-popup.css" },
        { file: "/modules/assets/template-admin/vendor/bootstrap-datepicker/css/bootstrap-datepicker3.css" },
        { file: "/modules/assets/template-admin/css/theme.css" },
        { file: "/modules/assets/template-admin/css/skins/default.css" },
        { file: "/modules/assets/template-admin/css/custom.css" }
    ],

    manager:
    [
        { 
            file: "/modules/assets/template-admin/vendor/font-awesome/css/all.min.css",
            replacements: [
                {
                    find: "../webfonts/fa-brands-400.",
                    replace: "/modules/assets/template-admin/vendor/font-awesome/webfonts/fa-brands-400."
                },
                {
                    find: "../webfonts/fa-solid-900.",
                    replace: "/modules/assets/template-admin/vendor/font-awesome/webfonts/fa-solid-900."
                },
                {
                    find: "../webfonts/fa-regular-400.", 
                    replace: "/modules/assets/template-admin/vendor/font-awesome/webfonts/fa-regular-400."
                },
            ]

        },
        { file: "/modules/assets/template-admin/vendor/bootstrap/css/bootstrap.css" },
        { file: "/modules/assets/template-admin/vendor/pnotify/pnotify.custom.css" },
        { file: "/modules/assets/template-admin/vendor/animate/animate.compat.css" },
        { 
            file: "/modules/assets/template-admin/vendor/boxicons/css/boxicons.min.css",
            replacements:[
                {
                    find:"../fonts/boxicons.",
                    replace:"/modules/assets/template-admin/vendor/boxicons/fonts/boxicons."
                }
            ]
        },
        { file: "/modules/assets/template-admin/vendor/magnific-popup/magnific-popup.css" },
        { file: "/modules/assets/template-admin/vendor/bootstrap-datepicker/css/bootstrap-datepicker3.css" },
        { file: "/modules/assets/template-admin/vendor/jquery-ui/jquery-ui.css" },
        { file: "/modules/assets/template-admin/vendor/jquery-ui/jquery-ui.theme.css" },
        { file: "/modules/assets/template-admin/vendor/bootstrap-multiselect/css/bootstrap-multiselect.css" },
        { file: "/modules/assets/template-admin/vendor/morris/morris.css" },
        { file: "/modules/assets/template-admin/css/theme.css",
            replacements: [
                {
                    find: "../img/",
                    replace: "/modules/assets/template/manager/img/"
                }
            ]
            },
        { file: "/modules/assets/template-admin/css/skins/default.css" },
        { file: "/modules/assets/template-admin/vendor/morris/morris.css" },
        { file: "/modules/assets/template-admin/css/custom.css" },

        { 
            file: "/modules/assets/kendoui/styles/kendo.common.min.css",
            replacements:[
                {
                    find   : "fonts/glyphs/WebComponentsIcons.ttf",
                    replace: "/modules/assets/kendoui/styles/fonts/glyphs/WebComponentsIcons.ttf"
                },
            ]
        },
        { 
            file: "/modules/assets/kendoui/styles/kendo.default-ocean-blue.min.css",
            replacements:[
                {
                    find   : "Default/loading-image.gif",
                    replace: "/modules/assets/kendoui/styles/Default/loading-image.gif"
                }
            ]
        },
        { 
            file: "/modules/assets/kendoui/styles/kendo.default.mobile.min.css",
            replacements:[
                {
                    find   : "images/kendoui.woff",
                    replace: "/modules/assets/kendoui/styles/images/kendoui.woff"
                },
                {
                    find   : "images/kendoui.ttf",
                    replace: "/modules/assets/kendoui/styles/images/kendoui.ttf"
                }
            ]
        },        
    ]

}