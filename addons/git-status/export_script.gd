@tool
extends EditorExportPlugin

const utility_script := preload('utility.gd')

func _get_name() -> String:
  return 'GitStatus'

func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
  var git_status : utility_script.Info
  git_status = utility_script.new().read_status_from_git()
  if git_status.hash.length() > 0:
    print('Exporting with git hash: %s%s' %
          [git_status.hash, '+changes' if git_status.modified else ''])
    var json_text = git_status.to_json()
    add_file('res://git-status.txt', json_text.to_ascii_buffer(), false)
  else:
    print('Exporting without git hash')
