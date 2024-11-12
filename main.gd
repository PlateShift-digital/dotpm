extends Node

var result_code: int = 0
var arguments: Array = []
var options: Dictionary = {}

var commands: Dictionary = {
	'install': preload('res://command/install.gd'),
	'update': preload('res://command/update.gd'),
}


func _ready() -> void:
	_parse_input_args()

	if not PackageMetaReader.package_configuration_exists():
		printerr('dotpm.json not found in current work directory!')
		get_tree().quit(1)
		return

	var command_node: BaseCommand
	var command: String

	if arguments.size() > 0 and arguments[0] != 'help':
		command = arguments.pop_front()

		if commands.has(command):
			command_node = commands[command].new()
			add_child(command_node)

			result_code = command_node.execute(arguments, options)
		else:
			print('command unknown: "' + command + '"')
			print_help()
			result_code = 128
	else:
		print_help()

	get_tree().quit(result_code)
	queue_free()

func _parse_input_args() -> void:
	for input in OS.get_cmdline_args():
		if input.begins_with('--'):
			var equal_sep = input.find('=')
			if equal_sep != -1:
				options[input.substr(2, equal_sep - 2)] = input.substr(equal_sep + 1)
			else:
				options[input.substr(2)] = true
		elif input.begins_with('-'):
			if input.length() > 2:
				options[input.substr(1, 1)[0]] = input.substr(2)
			else:
				options[input.substr(1, 1)[0]] = true
		else:
			arguments.append(input)

func print_help() -> void:
	var command_node: BaseCommand

	print('Available commands:')
	for command_name: String in commands:
		command_node = commands[command_name].new()
		print(
			('  ' + command_name + ': ').rpad(15),
			command_node.description()
		)
		command_node.free()
