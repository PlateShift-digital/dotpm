extends BaseCommand

var update_command: GDScript = preload('res://command/update.gd')


func description() -> String:
	return 'Installs all dependencies according to lock file (executes update if .lock not present)'

func execute(command: Array, options: Dictionary) -> int:
	if not PackageMetaReader.package_lock_exists():
		print('lock file does not exist... updating dependencies to generate it...')

		var command_node: BaseCommand = update_command.new()
		get_parent().add_child(command_node)
		queue_free()

		return command_node.execute(command, options)

	#print(OS.execute('git', ['status'], output, true))
	#var map_file: FileAccess = FileAccess.open(cwd + '/input_map.conf', FileAccess.WRITE)
	#map_file.store_string('wah!!')
	#map_file.close()

	print_debug(command, options)
	return 1
