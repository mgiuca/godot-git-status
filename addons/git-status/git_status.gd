## Utility to get information about the current project's git status.
##
## Provides the [method get_status] API to return git status, which reflects
## the live git repo status when running in the editor, and the git status
## at export time, when running an exported build.
class_name GitStatus
extends Object

const EXPORT_FILENAME := 'res://.git_status.json'

## Information about the current git working tree.
class Info:
  ## The hash of the HEAD revision in the git tree. Empty if missing.
  var hash : String
  ## Whether any files have been modified (staged or not) without being
  ## committed.
  var modified : bool

  ## Converts the info to a JSON string for storage.
  func to_json() -> String:
    var dict = {'hash': hash, 'modified': modified}
    return JSON.stringify(dict, '  ')

  ## Loads a JSON string into an [Info] object.
  static func from_json(json: String) -> Info:
    var info : Info = Info.new()
    var dict : Dictionary = JSON.parse_string(json)
    info.hash = dict.get('hash', '')
    info.modified = dict.get('modified', false)
    return info

## Gets the current git hash.[br]
## [br]
## Behaviour varies depending on whether the project was exported or is running
## in the editor:[br]
## - In the editor, gets the real git hash from the current working directory,
## assuming it is inside a git repository.[br]
## - In an exported project, reads the hash that was saved during export.
static func get_status() -> Info:
  if OS.has_feature('editor'):
    # In-editor - get from the git shell command.
    return _read_status_from_git()
  else:
    # Exported - read from the file.
    var file = FileAccess.open(EXPORT_FILENAME, FileAccess.READ)
    if file == null:
      return Info.new()
    return Info.from_json(file.get_as_text())

## Gets the current git hash from running the system [code]git[/code] command in
## the project directory.[br]
## [br]
## [b]WARNING[/b]: Do not use this from within a game, as it directly calls the
## [code]git[/code] command (which won't work on end-user machines). Instead,
## use [method get_hash] which uses the hash saved during the export.
static func _read_status_from_git() -> Info:
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
