module.exports = {
    languageOptions: {
        parserOptions: {
            sourceType: "module",
            ecmaVersion: 2022,
        },
        globals: {
            "$": "readonly",
            "AP": "readonly",
            "NM": "readonly",
            "kendo": "readonly",
            "alert": "writable",
            "window": "readonly",
            "module": "writable",
            "console": "readonly",
            "bootbox": "readonly",
            "document": "readonly",
            "pageData": "readonly",
            "markerjs3": "readonly",
            "setTimeout": "readonly",
            "FileReader": "readonly",
            "html2canvas": "readonly",
            "localStorage": "readonly"
        }
    },
    files: [ "**/*.js" ],
    rules: {
        "eqeqeq": "off",
        "quotes": [ "warn", "double" ],
        "one-var": [ "warn", "never" ],
        "wrap-iife": "warn",
        "comma-style": "warn",
        "dot-notation": "warn",
        "prefer-const": "warn",
        "block-spacing": "warn",
        "comma-spacing": "warn",
        "spaced-comment": "warn",
        "no-nested-ternary": "warn",
        "no-trailing-spaces": "warn",
        "function-paren-newline": "off",
        "no-multiple-empty-lines": "warn",
        "newline-per-chained-call": [
            "warn", {
                "ignoreChainWithDepth": 3
            }
        ],

        "semi": "error",
        "curly": "error",
        "no-eval": "error",
        "no-undef": "error",
        "no-iterator": "error",
        "no-new-func": "error",
        "no-dupe-keys": "error",
        "no-dupe-args": "error",
        "no-loop-func": "error",
        "no-new-object": "error",
        "no-else-return": "error",
        "no-new-wrappers": "error",
        "no-multi-assign": "error",
        "no-const-assign": "error",
        "no-useless-escape": "error",
        "no-param-reassign": "error",
        "no-mixed-operators": "error",
        "no-duplicate-imports": "error",
        "no-case-declarations": "error",
        "no-array-constructor": "error",
        "no-dupe-class-members": "error",
        "array-callback-return": "error",
        "brace-style": [ "error", "1tbs", { "allowSingleLine": true } ],
        "space-before-function-paren": [ "error", "never" ],
        "space-in-parens": [ "error", "always" ],
        "array-bracket-spacing": [ "error", "always" ],
        "object-curly-spacing": [ "error", "always" ],
        "indent": [ "error", 4 ]
    }
};
