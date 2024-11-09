class_name BaseCommand
extends Node

var work_dir: String
var user_home: String
var cache_dir: String


func _init(p_work_dir: String, p_user_home: String) -> void:
	work_dir = p_work_dir
	user_home = p_user_home

	if OS.get_environment('DOTPM_CACHE_DIR'):
		cache_dir = OS.get_environment('DOTPM_CACHE_DIR')
	else:
		cache_dir = user_home + '/.dotpm/cache'

func description() -> String:
	return ''

func execute(_command: Array, _options: Dictionary) -> int:
	return 128
