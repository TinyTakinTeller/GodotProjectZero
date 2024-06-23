extends Resource

var error := {
	#region Name Checks
	"function-name": "Validates if function name conforms to snake_case, _private_snake_case, or _on_PascalCase_snake_case.",
	"class-name": "Validates if class name conforms to PascalCase.",
	"sub-class-name": "Validates if class name conforms to _PrivatePascalCase.",
	"signal-name": "Validates if signal name conforms to PascalCase.",
	"class-variable-name": "Validates if class variable name conforms to snake_case or _private_snake_case.",
	"class-load-variable-name": "Validates if class load variable (var variable = load(...)) name conforms to PascalCase, snake_case or private_snake_case.",
	"function-variable-name": "alidates if function variable name conforms to snake_case.",
	"function-preload-variable-name": "Validates if function preload variable (var Variable = preload(...)) name conforms to PascalCase.",
	"function-argument-name": "Validates if function argument (formal parameter) name conforms to snake_case or _private_snake_case.",
	"loop-variable-name": "Validates if loop variable name conforms to snake_case or _private_snake_case.",
	"enum-name": "Validates if enum name conforms to PascalCase.",
	"enum-element-name": "Validates if enum element name conforms to UPPER_SNAKE_CASE.",
	"constant-name": "Validates if constant name conforms to UPPER_SNAKE_CASE.",
	"load-constant-name": "Validates if load constant (const constant = load(...)) name conforms to PascalCase, snake_case or private_snake_case.",
	#endregion

	#region Basic Checks
	"duplicated-load": "Copy-pasted load(...) for the same path e.g. load('res://asdf.tscn') in multiple places. To fix, simply extract string to constant.",
	"expression-not-assigned": "Standalone expression like 1 + 1 which is not used in any way. To fix, simply remove that expression.",
	"unnecessary-pass": "Pass which is not the only expression on class or function body. To fix, simple remove that pass statement.",
	"unused-argument": "Unused funtion argument. To fix, simply remove it or mark as explicitly unused by prefixing with underscore _ e.g. _unused_arg.",
	"comparison-with-itself": "Redundant comparison like e.g. x == x which is always true. To fix, simply remove that expression.",
	#endregion

	#region Class Checks
	"private-method-call": """private (prefixed with underscore _) function was called.
		E.g. player._private_func(). To fix, redesign your approach so that private function is not being called.""",
	"class-definitions-order": "Class statements are not in order.",
	#endregion

	#region Design Checks
	"max-public-methods": "Validates maximum number of public methods (class-level functions).",
	"function-arguments-number": "Validates number of function arguments.",
	#endregion

	#region Format Checks
	"max-file-lines": "Validates maximum number of file lines.",
	"trailing-whitespace": "Validates if any trailing whitespaces are present.",
	"max-line-length": "Validates maxium line length for each line.",
	"mixed-tabs-and-spaces": "Validates if either only tabs or only spaces are used for indentation.",
	#endregion

	#region Misc Checks
	"no-elif-return": "Validates if unnecessary elif is present in case if body was ended with return.",
	"no-else-return": "Validates if unnecessary else is present in case if (and each elif) body was ended with return."
	#endregion
}
