extends Node

## Gets the current git hash.
## Behaviour varies depending on whether the project was exported or is running
## in the editor:
## - In the editor, calls read_hash_from_git() to get the real git hash from
##   the current working directory.
## - In an exported project, reads the hash that was saved during export.
func get_hash() -> String:
  if OS.has_feature('editor'):
    # In-editor - get from the git shell command.
    return read_hash_from_git()
  else:
    # Exported - read from the file.
    var file = FileAccess.open('res://git-hash.txt', FileAccess.READ)
    if file == null:
      return ''
    return file.get_as_text()

## Gets the current git hash from running the system "git" command in the
## current directory. WARNING: Do not use this from within a game, as it
## directly calls git (which won't work on end-user machines). Instead, use
## get_hash() which uses the hash saved during the export.
func read_hash_from_git() -> String:
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
