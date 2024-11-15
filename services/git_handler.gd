extends Node


func clone(source: String, target: String) -> int:
	return OS.execute('git', [
		'clone',
		source,
		target,
	])

func clone_branch(source: String, branch: String, target: String) -> int:
	return OS.execute('git', [
		'clone',
		'--branch=' + branch,
		source,
		target,
	])

func execute(clone_dir: String, command_parts: Array) -> int:
	var command: Array = ['-C', clone_dir]
	command.append_array(command_parts)

	return OS.execute('git', command)

func execute_with_result(clone_dir: String, command_parts: Array) -> String:
	var output: Array = []
	var command: Array = ['-C', clone_dir]
	command.append_array(command_parts)

	OS.execute('git', command, output)

	return ''.join(output)
