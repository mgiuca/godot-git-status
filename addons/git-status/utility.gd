extends Node

## Information about the current git working tree.
class Info:
  ## The hash of the HEAD revision in the git tree. Empty if missing.
  var hash : String
  ## Whether any files have been modified (staged or not) without being
  ## committed.
  var modified : bool

  func to_json() -> String:
    var dict = {'hash': hash, 'modified': modified}
    return JSON.stringify(dict, '  ')

  static func from_json(json: String) -> Info:
    var info : Info = Info.new()
    var dict : Dictionary = JSON.parse_string(json)
    info.hash = dict.get('hash', '')
    info.modified = dict.get('modified', false)
    return info

## Gets the current git hash.
## Behaviour varies depending on whether the project was exported or is running
## in the editor:
## - In the editor, calls read_hash_from_git() to get the real git hash from
##   the current working directory.
## - In an exported project, reads the hash that was saved during export.
func get_status() -> Info:
  if OS.has_feature('editor'):
    # In-editor - get from the git shell command.
    return read_status_from_git()
  else:
    # Exported - read from the file.
    var file = FileAccess.open('res://git-status.txt', FileAccess.READ)
    if file == null:
      return Info.new()
    return Info.from_json(file.get_as_text())

## Gets the current git hash from running the system "git" command in the
## current directory. WARNING: Do not use this from within a game, as it
## directly calls git (which won't work on end-user machines). Instead, use
## get_hash() which uses the hash saved during the export.
func read_status_from_git() -> Info:
  var info : Info = Info.new()
  var output : Array
  # Use git rev-parse to get the hash.
  var exit_code : int = \
    OS.execute('git', ['rev-parse', 'HEAD'], output)

  if exit_code == 127:
    push_warning('GitStatus: git not found')
    return info
  elif exit_code != 0:
    push_warning('GitStatus: git rev-parse failed with code %d' % exit_code)
    return info

  if output.size() == 0 or output[0] is not String:
    push_warning('GitStatus: unexpected OS.execute output')
    return info

  var stdout : String = output[0] as String
  info.hash = stdout.rstrip('\n')

  # Use git status to get whether there are working dir changes.
  output.clear()
  exit_code = OS.execute('git', ['status', '--porcelain=1'], output)
  if exit_code == 127:
    push_warning('GitStatus: git not found')
    return info
  elif exit_code != 0:
    push_warning('GitStatus: git status failed with code %d' % exit_code)
    return info

  if output.size() == 0 or output[0] is not String:
    push_warning('GitStatus: unexpected OS.execute output')
    return info

  stdout = output[0] as String
  info.modified = stdout.length() > 0

  return info
