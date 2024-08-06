#------------------------------------------------------------------------------
#-- Copyright (c) 2022-Present Lyaaaaa Games
#--
#-- Author : Lyaaaaaaaaaaaaaaa
#--
#-- Implementation Notes:
#--  - Collection of useful functions using the DirAccess class
#--
#-- Anticipated changes:
#--  - Rewrite get_files_names to use the very simple get_files_at method.
#--
#-- Portability issue:
#--  - All the path have to be absolute (res:// and user:// work though)!
#--
#-- Changelog:
#--  - 06/08/2024 Lyaaaaa
#--    - Renamed cut_file into move_file to be more explicit.
#------------------------------------------------------------------------------
@tool
class_name Dir_Utils
extends DirAccess

static func get_files_names(p_path_to_folder : String,
                            p_get_extension  : bool = true) -> PackedStringArray:
    var files_names : PackedStringArray
    var directory := DirAccess.open(p_path_to_folder)
    if directory:
        var skip_navigation = true
        var skip_hidden     = true
        directory.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
        var file_name = directory.get_next()

        while file_name != "":
            if directory.current_is_dir() == false:
                if p_get_extension:
                    files_names.append(file_name)
                else:
                    files_names.append(file_name.get_basename())
            file_name = directory.get_next()
    else:
        var message = "Error getting files at " + p_path_to_folder
        message += ". Error code: " + str(DirAccess.get_open_error())
        push_warning(message)

    return files_names


static func get_folders_names(p_path_to_folder : String) -> PackedStringArray:
    var folders_names : PackedStringArray
    var directory := DirAccess.open(p_path_to_folder)
    if directory:
        var skip_navigation = true
        var skip_hidden     = true
        directory.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
        var folder_name = directory.get_next()

        while folder_name != "":
            if directory.current_is_dir() == true:
                folders_names.append(folder_name)
            folder_name = directory.get_next()
    else:
        var message = "Error getting folders at " + p_path_to_folder
        message += ". Error code: " + str(DirAccess.get_open_error())
        push_warning(message)

    return folders_names


static func delete(p_path_to_file : String) -> bool:
    var error : int
    error = DirAccess.remove_absolute(p_path_to_file)

    if error == OK:
        return true
    else:
        var message = "Error deleting " + p_path_to_file
        message += ". Error code: " + str(error)
        push_warning(message)
        return false


static func delete_dir(p_path : String) -> bool:
    var files = get_files_names(p_path)

    for file in files:
        delete(p_path.path_join(file))

    return delete(p_path)


static func rename_file(p_from        : String,
                        p_to          : String,
                        p_create_path : bool = false) -> bool:
    var error : int

    if p_create_path:
        create_dir_recursive(p_to.get_base_dir())

    error = DirAccess.rename_absolute(p_from, p_to)

    if error == OK:
        push_warning("Moved " + p_from + " into " + p_to)
        return true
    else:
        var message = "Error moving " + p_from + " to " + p_to
        message += ". Error code: " + str(error)
        push_error(message)
        return false


static func move_file(p_from        : String,
                      p_to          : String,
                      p_create_path : bool = true) -> bool:
    # This method is just an alias. Because 'cut' sounds more explicit than
    #   'rename'. It also has more debug info.
    if FileAccess.file_exists(p_from):
        if DirAccess.dir_exists_absolute(p_to.get_base_dir()):
            p_create_path = false

        return rename_file(p_from, p_to, p_create_path)

    else:
        var message = "Can't move file. The source folder: " + p_from
        message += " doesn't exist."
        push_error(message)
        return false



static func create_dir_recursive(p_path : String) -> bool:
    var error : int
    error = DirAccess.make_dir_recursive_absolute(p_path)

    if error == OK:
        return true
    else:
        var message = "Error creating directories recursively: " + p_path
        message += ". Error code: " + str(error)
        push_warning(message)
        return false


static func globalize_res_path(p_relative_path : String) -> String:
    if OS.has_feature("editor") or p_relative_path.find("user://") != -1:
        return ProjectSettings.globalize_path(p_relative_path)
    else:
        var path : String
        path = OS.get_executable_path().get_base_dir()
        path = path.path_join(p_relative_path.replace("res://", ""))
        return path


static func get_folder_size(p_path : String) -> int:
    if DirAccess.dir_exists_absolute(p_path):
        var files_names : PackedStringArray = DirAccess.get_files_at(p_path)
        var total_size : int = 0


        for file_name in files_names:
            var file := FileAccess.open(p_path.path_join(file_name), FileAccess.READ)
            if file:
                total_size += file.get_length()
            else:
                var message = "Couldn't open " + p_path + file_name
                message += ". Error: " + str(FileAccess.get_open_error())
                push_error(message)

        return total_size
    else:
        return 0


static func is_empty(p_path_to_directory) -> bool:
    if DirAccess.dir_exists_absolute(p_path_to_directory):
        var files = DirAccess.get_files_at(p_path_to_directory)
        if files.is_empty():
            return true
        else:
            return false
    else:
        push_warning(p_path_to_directory + " doesn't exist.")
        return true


static func get_file_name_with_extension(p_full_path : String) -> String:
    return p_full_path.get_file()


static func get_file_name(p_full_path : String) -> String:
    var file_name = p_full_path.get_file()
    var extension = get_extension_with_dot(p_full_path)

    file_name = file_name.replace(extension, "")
    return file_name


static func remove_extension(p_file_name : String) -> String:
    return get_file_name(p_file_name)


static func get_extension_with_dot(p_full_path : String) -> String:
    var extension = '.' + p_full_path.get_extension()
    return extension


static func copy_file(p_from_absolute : String, p_to_absolute : String) -> bool:
    var error : int = DirAccess.copy_absolute(p_from_absolute, p_to_absolute)

    if error == OK:
        return true
    else:
        var message := "Couldn't copy " + p_from_absolute + " to " + p_to_absolute
        message += " Error : " + str(error)
        push_error(message)
        return false

