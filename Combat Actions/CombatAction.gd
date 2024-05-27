class_name CombatAction
extends Resource

@export var display_name = "Action x (DMG)"
@export_multiline var description

@export var mp_cost: int = 0

@export var damage: int = 0
@export var heal: int = 0

@export var buff: bool
	# If true, select a target & effect/bonus

@export var debuff: bool
	# if true select a target & effect

@export var status: Array = []

@export var hit_chance: float 
@export var status_duration: int #Int = number of turns/rounds that the status is effective.
