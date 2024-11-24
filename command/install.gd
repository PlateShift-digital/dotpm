extends BaseCommand

const UPDATE_COMMAND: GDScript = preload('res://command/update.gd')


func description() -> String:
	return 'Installs all dependencies according to lock file (executes update if .lock not present)'

func execute(command: Array, options: Dictionary) -> int:
	if not PackageMetaReader.package_lock_exists():
		print('lock file does not exist... updating dependencies to generate it...')

		var command_node: BaseCommand = UPDATE_COMMAND.new()
		get_parent().add_child(command_node)
		queue_free()

		return command_node.execute(command, options)

	PackageMetaReader.load_lock_file()

	if ERR_FILE_CORRUPT == PackageMetaReader.validate_lock_hash():
		print('lock file is not in sync with changes from dotpm.json!')
		print('run the update command to fix this warning.')
		print('')

	PackageMetaReader.load_installed_packages()
	CacheHandler.build_package_cache()
	PackageInstaller.synchronise_packages()
	PackageMetaReader.write_installed_packages()

	return 1
