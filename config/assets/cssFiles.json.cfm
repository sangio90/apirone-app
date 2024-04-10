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
            file: "/modules/assets/template-public/vendor/fontawesome-free/css/all.min.css",
            replacements: [
                {
                    find: "../webfonts/fa-brands-400.",
                    replace: "/modules/assets/template-public/vendor/fontawesome-free/webfonts/fa-brands-400."
                },
                {
                    find: "../webfonts/fa-solid-900.",
                    replace: "/modules/assets/template-public/vendor/fontawesome-free/webfonts/fa-solid-900."
                },
                {
                    find: "../webfonts/fa-regular-400.", 
                    replace: "/modules/assets/template-public/vendor/fontawesome-free/webfonts/fa-regular-400."
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
        { file: "/modules/assets/template-admin/css/custom.css" }
    ]

}