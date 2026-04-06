class_name Component
extends Node

## Root node of the component. Its reccomended to create a
## getter function for this.
var root_node : Node
## The component manager for this component
var component_manager : ComponentManager

const PROPERTY_HINT_COMPONENT: PropertyHint = PROPERTY_HINT_MAX + _PROPERTY_HINT_COMP_MAGIC
const _PROPERTY_HINT_COMP_MAGIC: int = 1837423
