class_name FiniteStateTransition
extends Resource

## List of custom arguments for the advance expression. 
## All NodePaths will be parsed into Nodes.
@export var arguments: Dictionary[String, Variant]

## The advance expression for the transition. 
## Inherits all properties of the executing state.
## Reccomended to input only expressions resulting in a boolean value.
@export_custom(PROPERTY_HINT_EXPRESSION, "") var advance_expression: String

## The resulting State if the transition argument is true.
@export_node_path("FiniteState") var new_state: NodePath

var _expression := Expression.new()

func validate(state: FiniteState) -> bool:
	if not state:
		return false
	
	var args := arguments.duplicate()
	
	for key in args.keys():
		var x = args.get(key)
		if x is NodePath:
			args.set(key, state.get_node(x)) 
	
	var error = _expression.parse(advance_expression, args.keys())
	if error != OK:
		return false
	
	var result = _expression.execute(args.values(), state)
	if _expression.has_execute_failed():
		return false
	
	return result
	
