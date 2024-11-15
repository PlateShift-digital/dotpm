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

	PackageMetaReader.load_lock_file()
	PackageMetaReader.load_installed_packages()
	CacheHandler.build_package_cache()
	PackageInstaller.synchronise_packages()
	PackageMetaReader.write_installed_packages()

	return 1
