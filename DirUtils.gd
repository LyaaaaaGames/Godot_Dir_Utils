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
#--  - 26/11/2021 Lyaaaaa
#--    - Created the file
#--
#--  - 09/12/2021 Lyaaaaa
#--    - Updated get_files_names to choose if it must include the files' extensions
#--    - Added rename_file function.
#--
#--  - 20/12/2021 Lyaaaaa
#--    - Added get_folders_names function.
#--
#--  - 23/12/2021 Lyaaaaa
#--    - Updated rename_file to add a new parameter "p_create_path" to  call
#--        create_dir_recursive from it.
#--    - Created an alias method named cut_file, it just calls rename_file.
#--    - Added create_dir_recursive method.
#--
#--  - 25/12/2021 Lyaaaaa
#--    - Added globalize_res_path function.
#--
#--  - 10/02/2022 Lyaaaaa
#--    - Replaced print by push_warning.
#--
#--  - 28/02/2022 Lyaaaaa
#--    - Added delete_dir method which deletes the files in a folder, then the folder.
#--
#--  - 21/03/2022 Lyaaaaa
#--    - Updated globalize_res_path to work with "user://" paths.
#--
#--  - 06/11/2022 Lyaaaaa
#--    - Replaced push_warning by GlobalVariables.warning.
#--
#--  - 30/11/2022 Lyaaaaa
#--    - globalize_res_path is now a static method cuz why not.
#--
#--  - 15/09/2023 Lyaaaaa
#--    - Updated rename_file to log info even when it works.
#--
#--  - 09/10/2023 Lyaaaaa
#--    - Upgrade to godot 4
#--    - create_dir_recursive, cut_file and rename_file now are static and use
#--        the static methods of DirAccess (which require absolute path!!)
#--
#--  - 10/10/2023 Lyaaaaa
#--    - get_folders_names and get_files_names (all functions) are now static.
#--
#--  - 12/10/2023 Lyaaaaa
#--    - Updated delete and delete_dir to become static.
#--    - Delete now uses delete_absolute making it possible to be static.
#--        DirAccess statics functions only work with absolute path but res://
#--        and user:// work too!
#--
#--  - 16/10/2023 Lyaaaaa
#--    - Fixed error when calling methods of mother class. Since everything
#--        is static it requires to specify the class of the methods.
#--    - Updated cut_file to correctly check if the file to move exist and if
#--        the new destination exist.
#--    - Updated delete_dir to give the proper path (not only the files name)
#--        of the files to remove inside the folder to remove.
#--
#--  08/11/2023 Lyaaaaa
#--    - Added get_folder_size method.
#--
#--  13/11/2023 Lyaaaaa
#--    - Fixed a typo in get_folders_names when it was failing.
#--    - Updated delete_dir to use path_join to be more efficient.
#--    - Updated rename_file to replace the word "copied" by "moved" in the logs.
#--    - Updated get_folder_size to just return 0 if the folder doesn't exist.
#--
#--  07/12/2023 Lyaaaaa
#--    - Replaced all the globalvariable.warning call for push_warning or push_error.
#--    - Added is_empty static func.
#--
#--  14/12/2023 Lyaaaaa
#--    - Updated error message in rename_file.
#--
#--  - 03/01/2024 Lyaaaaa
#--    - Added get_file_name_with_extension, get_file_name and get_extension_with_dot
#--        static methods.
#--
#--  - 04/01/2024 Lyaaaaa
#--    - Added remove_extension which is a simple alias of get_file_name.
#--
#--  - 07/02/2024 Lyaaaaa
#--    - Added copy_file method.
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


static func cut_file(p_from        : String,
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
