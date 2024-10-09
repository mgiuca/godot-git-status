@tool
extends EditorExportPlugin

func _get_name() -> String:
  return 'GitStatus'

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
  var git_hash : String
  git_hash = get_git_hash()
  if git_hash.length() > 0:
    print('Exporting with git hash: %s' % git_hash)
    add_file('res://git-hash.txt', git_hash.to_ascii_buffer(), false)
  else:
    print('Exporting without git hash')

## Gets the current git hash in the working directory.
func get_git_hash() -> String:
  var output : Array
  var exit_code = OS.execute('git', ['show-ref', '--head', 'HEAD', '--hash'],
                             output)

  if exit_code == 127:
    push_warning('GitStatus: git not found')
    return ''
  elif exit_code != 0:
    push_warning('GitStatus: git failed with code %d' % exit_code)
    return ''

  if output.size() == 0 or output[0] is not String:
    push_warning('GitStatus: unexpected OS.execute output')
    return ''

  var stdout : String = output[0] as String
  return stdout.rstrip('\n')
