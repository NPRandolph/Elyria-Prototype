
class_name Character
extends CharacterBody2D

@export var is_player: bool

@export var archetype = Archetype

@export_group("Max Values")
@export var max_hp: int:
	get:
		return (10 + archetype.strength)
@export var max_mp: int:
	get:
		return (8 + archetype.magic) 

@export_group("Stats")

@export var cur_hp: int = 0
@export var cur_mp: int = 0

@export var mp_regen: int:
	get:
		return archetype.focus

@export var attack: int:
	get:
		return archetype.strength

@export var defense: int:
	get:
		return archetype.focus

@export var evasion: int:
	get:
		return (archetype.focus * 10)
@export var resolve: int:
	get:
		return (archetype.strength * 10)

@export_group("Combat Actions")
@export var combat_actions: Array

@export var opponent: Node


# On Readys below

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

@onready var hp_bar: ProgressBar = get_node("HPBar")
@onready var hp_text: Label = get_node("HPBar/HPText")
@onready var mp_bar: ProgressBar = get_node("MPBar")
@onready var mp_text: Label = get_node("MPBar/MPText")

func _ready():
	cur_hp = max_hp
	cur_mp = max_mp
	get_node("/root/BattleScene").character_begin_turn.connect(_on_character_begin_turn)
	hp_bar.max_value = max_hp
	mp_bar.max_value = max_mp
	_update_hp_bar()
	_update_mp_bar()

func take_damage(damage):
	cur_hp -= damage
	_update_hp_bar()
	if cur_hp <= 0:
		get_node("/root/BattleScene").character_died(self)
		queue_free()

func heal(amount):
	cur_hp += amount
	
	if cur_hp > max_hp:
		cur_hp = max_hp
		
	_update_hp_bar()

func _update_hp_bar():
	hp_bar.value = cur_hp
	hp_text.text = str(cur_hp, "/", max_hp)

func _update_mp_bar():
	mp_bar.value = cur_mp
	mp_text.text = str(cur_mp, "/", max_mp)

func _regenerate_mp():
	cur_mp += mp_regen
	if cur_mp > max_mp:
		cur_mp = max_mp
	_update_mp_bar()

func _on_character_begin_turn(character):
	#if cur_mp > max_mp:
	_regenerate_mp()
	if character == self and is_player == false:
		_decide_combat_action()

func cast_combat_action(action):
	if action.damage > 0:
		opponent.take_damage(action.damage)
	elif action.heal > 0:
		heal(action.heal)
		
	get_node("/root/BattleScene").end_current_turn()

func _decide_combat_action():
	var hp_percent = float(cur_hp) / float(max_hp)
	
	for i in combat_actions:
		var action = i as CombatAction
		
		if action.heal > 0:
			if randf() > hp_percent + 0.2:
				cast_combat_action(action)
				return
			else:
				continue
		else:
			cast_combat_action(action)
			return
