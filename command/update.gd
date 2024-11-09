extends BaseCommand

var resolved_requirements: Dictionary = {}
var installed: Dictionary = {}


func description() -> String:
	return 'Updates all dependencies according to dotpm.json'

func execute(_command: Array, _options: Dictionary) -> int:
	DirAccess.make_dir_recursive_absolute(cache_dir)

	printraw('parsing dependencies... ')
	var project_config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(work_dir + '/dotpm.json'))

	if project_config.has('require'):
		for project: String in project_config.require:
			resolved_requirements[project] = {
				'data': get_requested_project_data(project),
				'requested': project_config.require[project],
			}
	print('done')

	for request: String in resolved_requirements:
		var request_data: Dictionary = resolved_requirements[request]
		var cache_target: String = cache_dir + '/' + request

		if request_data.requested.begins_with('@'):
			print_debug(clone_into_cache(cache_target, request_data))
		elif request_data.data.versions.has(request_data.requested):
			print_debug('it has the version')
		else: # try to clone it directly as the version is unknown
			print_debug('version unknown, trying to clone it directly')

	return 1

func get_requested_project_data(project: String) -> Dictionary:
	if project == 'plateshift/advanced-input-map':
		return {
			'code_source': 'https://github.com/PlateShift-digital/advanced-input-map.git',
			'versions': {
				#'@master': {
					#'type': 'clone',
					#'branch': 'master',
				#},
			}
		}

	return {}

func clone_into_cache(cache_target: String, request_data: Dictionary) -> int:
	var command_options: Array

	if DirAccess.dir_exists_absolute(cache_target):
		print_debug('user request branch but cache already has a clone')
		command_options = [
			'-C',
			cache_target,
			'pull'
		]
		return OS.execute('git', command_options)
	else:
		print_debug('user requested a branch directly')
		command_options = [
			'clone',
			'--branch=' + request_data.requested.substr(1),
			request_data.data.code_source,
			cache_target,
		]
		return OS.execute('git', command_options)
