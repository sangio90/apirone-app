module.exports = {
	languageOptions: {
		parserOptions: {
			sourceType: "module",
			ecmaVersion: 2020
		},
		globals: {
			"$": "readonly",
			"AP": "readonly",
			"NM": "readonly",
			"alert": "writable",
			"module": "writable",
			"bootbox": "readonly",
			"document": "readonly",
			"setTimeout": "readonly",
			"localStorage": "readonly",
			"window": "readonly",
			"kendo": "readonly",
			"console": "readonly",
		}
	},
	rules: {
		"eqeqeq": "off",
		"quotes": ["warn", "double"],
		"one-var": ["warn", "never"],
		"wrap-iife": "warn",
		"comma-style": "warn",
		"dot-notation": "warn",
		"block-spacing": "warn",
		"comma-spacing": "warn",
		"spaced-comment": "warn",
		"space-in-parens": ["warn", "never"],
		"no-nested-ternary": "warn",
		"no-trailing-spaces": "warn",
		"array-bracket-spacing": "warn",
		"space-before-function-paren": ["never"],
		"function-paren-newline": "warn",
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
		"no-useless-escape": "error",
		"no-param-reassign": "error",
		"no-mixed-operators": "error",
		"no-duplicate-imports": "error",
		"no-case-declarations": "error",
		"no-array-constructor": "error",
		"no-dupe-class-members": "error",
		"array-callback-return": "error",
		"brace-style": ["error", "1tbs", { "allowSingleLine": true }]
	}
};