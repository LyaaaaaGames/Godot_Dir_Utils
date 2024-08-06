# Godot_Dir_Utils
Collection of useful functions using the DirAccess class

## Why this plugin?

For a project I had to do a lot of actions related to files and directories. So, I had to write a lot of functions to save me time.

Then, I started reusing these functions for others project. So, using it as a plugin with version numbers makes it simpler to share it.

Therefore, I'm sharing it with you as well.

## Features

- Get names of files inside a folder (with or without extension)
- Get names of folders inside a folder
- Delete a file
- Delete a directory
- Rename a file
- Move a file
- Create directories recursively (exemple create the following path `user://new_folder/new_subfolder/new_sub_sub_folder`)
- Globalize a path (Work for both inside and outside the editor!!!)
- Get the size of a folder
- Check if a folder is empty
- Get name of a file with its extension
- Get name of a file without its extension
- Remove the extension of a file name
- Get the extension (with a dot) of a file name
- Copy a file
- Usage of `push_warning` and `push_error` to inform you about problems
