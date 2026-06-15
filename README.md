# GitStatus addon for Godot

This simple addon lets you embed the git hash of your project in your Godot game
and display it somewhere. This is extremely handy for testing and reporting
bugs, as you can see the exact version of the project that is being used.

Ideally, the hash should be displayed somewhere subtle, on the game's menu where
it is unlikely to interfere but can be easily accessed by end users who need to
report an issue. This just provides an API; where you display it in the game's
UI is up to you.

## Functionality

- When running the project in the Godot editor, the API simply returns the hash
  of the current git repository in the project directory.
- When the project is exported, the plugin reads the git hash and stores it in
  the exported pack file.
- When running the exported project, the API reads the hash from the pack file
  (so it still works, even though the end user is not running the project inside
  a git repo).
- It also flags if there are any uncommitted changes (either unstaged modified
  files, staged modified files, or untracked files), for you to use as a warning
  to yourself. Having uncommitted changes means that the build is not cleanly
  based on a specific git commit, so you have no idea what it might contain. It
  is recommended that you display this flag and do not release builds containing
  uncommitted changes to users.

## Use cases

Knowing the exact git hash of an exported project is very useful for a number of
reasons:

- Just showing the version number alone can be misleading, as you might forget
  to increase the number, or you might make many test builds for a given version
  number before officially releasing it. Knowing the git hash helps you identify
  if you are using an old build of a given version number.
- When testing a build, you can confirm that it is exactly the git commit that
  you intended to release.
- When users report bugs, you can have them report the exact version string so
  you know exactly which git hash they are using.
- If you have a feedback form, you can automatically include the git hash along
  with the feedback in the report.

## Setup

1. Add the contents of `addons/git-status` into your `addons` directory.
2. In Project Settings > Plugins, turn on the GitStatus plugin.
3. Use `GitStatus.get_hash_string()` to get a simple short hash string, or
   `GitStatus.get_status()` to get a detailed object.
4. When you export your project, you should see "Exporting with git hash"
   printed to the output panel. This means the git hash will be available in the
   exported build.

See the example project in this repository for a demonstration.

Note that you will see "+changes" at the end of the hash whenever there are
uncommitted changes, which may be ugly, but serves as a reminder that your build
is not clean. This is perfectly normal while working on a project, but you
should make sure you don't release builds that display "+changes" to users. If
you wanted to, you could even check `get_status().modified` and complain loudly
on startup.

## Troubleshooting

- If `get_hash_string` returns "(no git)", or `get_status().hash` is empty, in
  the editor, it means the project is not in a git repo, or the `git` command is
  not working properly.
- If you see "(no git)" / empty string in an exported project, it means the
  above was true when you exported, or you did not have the plugin enabled when
  you exported.
- If you see "+changes", it means there are some uncommitted changes in the
  repository. Note that this includes untracked files (anything that shows up in
  `git status`). To avoid this, use
  [`.gitignore`](https://git-scm.com/docs/gitignore) to ignore any files that
  you don't want committed.
