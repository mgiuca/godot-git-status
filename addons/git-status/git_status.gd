@tool
extends EditorPlugin

const AUTOLOAD_NAME = 'GitStatus'

var export_plugin : EditorExportPlugin

func _enter_tree() -> void:
  export_plugin = preload('export_script.gd').new()
  add_export_plugin(export_plugin)

  # Make the GitStatus singleton available.
  add_autoload_singleton(AUTOLOAD_NAME, 'utility.gd')

func _exit_tree() -> void:
  remove_export_plugin(export_plugin)
  export_plugin = null

  remove_autoload_singleton(AUTOLOAD_NAME)
