#------------------------------------------------------------------------------
#-- Copyright (c) 2022-Present Lyaaaaa Games
#--
#-- Author : Lyaaaaaaaaaaaaaaa
#--
#-- Implementation Notes:
#--  - Unit file for the dir_utils class
#--
#-- Anticipated changes:
#--  -
#--
#-- Changelog:
#--  - 31/12/2021 Lyaaaaa
#--    - Created the file
#--
#--  - 28/02/2022 Lyaaaaa
#--    - Added test_delete_dir function.
#--
#--  - 10/10/2023 Lyaaaaa
#--    - Upgraded to Godot4
#--    - Replaced dir_util var by call of Dir_Utils directly.
#--    - test_create_dir_recursive calls Dir_Utils's delete instead of DirAccess
#--        remove.
#--
#--  - 16/10/2023 Lyaaaaa
#--    - Uses now DirAccess for its own method instead of Dir_Utils (Doesn't work
#--        if not initialized, it seems).
#--
#--  - 22/04/2024 Lyaaaaa
#--    - Updated test_folder path to "user://tests/"
#--    - Added a fourth file in files.
#--    - Added test_get_folder_size, test_is_empty, test_get_file_name_with_extension
#--        test_get_file_name, test_remove_extension, test_get_extension_with_dot,
#--        test_copy_file.
#--
#--  - 06/08/2024 Lyaaaaa
#--    - Renamed cut_file into move_file.
#--
#--  - 07/08/2024 Lyaaaaa
#--    - Updated test_delete to delete all the files declared in files
#--        (forgot to update it when added a fourth file in files var).
#--    - Updated test_get_folder_size to correctly do its job and to clean his mess.
#------------------------------------------------------------------------------
extends GutTest

var test_folder := "user://tests/"
var sub_folders : PackedStringArray = ["folder1/", "folder2/"]
var files       : PackedStringArray = ["file1", "file2", "file3.json", "file4.txt"]

func before_each():
    var dir = DirAccess.open("user://")
    dir.make_dir(test_folder)
    for folder in sub_folders:
        var path : String = test_folder + folder
        dir.make_dir(path)
        for file in files:
            create_file(file, test_folder + folder)


func after_each():
    for folder in sub_folders:
        var path : String = test_folder + folder
        for file in files:
            DirAccess.remove_absolute(path + file)
        DirAccess.remove_absolute(path)
    DirAccess.remove_absolute(test_folder)


func create_file(p_file_name, p_file_path):
    var file := FileAccess.open(p_file_path + p_file_name, FileAccess.WRITE)
    file.store_string("content")
    file.close()


func test_get_files_names():
    var has_extension : bool = false
    var files = Dir_Utils.get_files_names(test_folder + sub_folders[0] + '/')
    assert_typeof(files, TYPE_PACKED_STRING_ARRAY)
    assert_eq(files.size(), self.files.size())
    for file in files:
        assert_file_exists(test_folder + sub_folders[0] + file)

    files = Dir_Utils.get_files_names(test_folder + sub_folders[0] + '/', false)
    for file in files:
        if file.ends_with("json"):
            has_extension = true
    assert_false(has_extension, "get_files_names doesn't return extension when p_get_extension = false")


func test_get_folders_names():
    var folders = Dir_Utils.get_folders_names(test_folder)
    assert_typeof(folders, TYPE_PACKED_STRING_ARRAY)
    assert_eq(folders.size(), sub_folders.size())


func test_delete():
    assert_file_exists(test_folder + sub_folders[0] + files[0])
    var result = Dir_Utils.delete(test_folder + sub_folders[0] + files[0])
    assert_true(result, "Did delete return true for deleting a file.")
    assert_file_does_not_exist(test_folder + sub_folders[0] + files[0])

    Dir_Utils.delete(test_folder + sub_folders[0] + files[1])
    Dir_Utils.delete(test_folder + sub_folders[0] + files[2])
    Dir_Utils.delete(test_folder + sub_folders[0] + files[3])

    result = Dir_Utils.delete((test_folder + sub_folders[0]))
    assert_true(result, "Did delete return true for deleting a folder.")


func test_rename_file_no_creating_path():
    var from = test_folder + sub_folders[0] + files[0]
    var to   = test_folder + sub_folders[0] + "new_name"
    var result = Dir_Utils.rename_file(from, to)

    assert_true(result, "Did rename return true.")
    assert_file_does_not_exist(from)
    assert_file_exists(to)

    Dir_Utils.delete(to)


func test_rename_file_with_creating_path():
    var from = test_folder + sub_folders[0] + files[0]
    var to_folder = "new_folder/"
    var to   = test_folder + to_folder + "new_name"
    var result = Dir_Utils.rename_file(from, to, true)

    assert_true(result, "Did rename return true with p_create_path = true.")
    assert_file_does_not_exist(from)
    assert_file_exists(to)

    Dir_Utils.delete(to)
    Dir_Utils.delete(test_folder + to_folder)


func test_move_file():
    var from = test_folder + sub_folders[0] + files[0]
    var to_folder = "new_folder/"
    var to   = test_folder + to_folder + "new_name"
    var result = Dir_Utils.move_file(from, to, true)

    assert_true(result, "Did rename return true with p_create_path = true.")
    assert_file_does_not_exist(from)
    assert_file_exists(to)

    Dir_Utils.delete(to)
    Dir_Utils.delete(test_folder + to_folder)


func test_create_dir_recursive():
    var first_subfolder  = "recursive_folder/"
    var second_subfolder = "subfolder"
    var path = test_folder + first_subfolder + second_subfolder
    var result = Dir_Utils.create_dir_recursive(path)
    assert_true(result, "Did create_dir_recursive return true?")
    result = DirAccess.dir_exists_absolute(path)
    assert_true(result, "Do the directories exist?")
    Dir_Utils.delete(path)
    Dir_Utils.delete(test_folder + first_subfolder)


func test_globalize_res_path():
    var res_path = "res://test"
    var result = Dir_Utils.globalize_res_path(res_path)
    assert_typeof(result, TYPE_STRING)
    assert_ne(result, res_path)


func test_delete_dir():
    var path = test_folder + sub_folders[0]
    assert_true(Dir_Utils.delete_dir(path), "delete_dir returns true")
    assert_file_does_not_exist(path)


func test_get_folder_size():
    var size = Dir_Utils.get_folder_size(test_folder + sub_folders[0])
    var msg = "get folder size returns an int"
    assert_typeof(size, TYPE_INT, msg)

    msg = "Test folder size is superior to 0"
    assert_gt(size, 0, msg)

    msg = "Get folder size on bad path returns 0"
    assert_eq(Dir_Utils.get_folder_size("Bad_Path"), 0, msg)


func test_is_empty() -> void:
    var path = test_folder.path_join("empty_folder")
    Dir_Utils.create_dir_recursive(path)
    assert_true(Dir_Utils.is_empty(path))
    assert_false(Dir_Utils.is_empty(test_folder.path_join(sub_folders[0])))

    Dir_Utils.delete_dir(path)


func test_get_file_name_with_extension() -> void:
    var path = test_folder.path_join(sub_folders[0].path_join(files[2]))
    var path2 = test_folder.path_join(sub_folders[0].path_join(files[3]))
    assert_string_ends_with(Dir_Utils.get_file_name_with_extension(path), ".json")
    assert_string_ends_with(Dir_Utils.get_file_name_with_extension(path2), ".txt")

func test_get_file_name() -> void:
    var path := test_folder.path_join(sub_folders[0].path_join(files[2]))
    var path2 := test_folder.path_join(sub_folders[0].path_join(files[3]))

    var name = Dir_Utils.get_file_name(path)
    var name2 = Dir_Utils.get_file_name(path2)

    assert_eq(name, "file3")
    assert_eq(name2, "file4")


func test_remove_extension() -> void:
    var name = Dir_Utils.remove_extension("file.json")
    assert_eq(name, "file")


func test_get_extension_with_dot() -> void:
    var extension = Dir_Utils.get_extension_with_dot("file.json")
    assert_eq(extension, ".json")


func test_copy_file() -> void:
    var destination = test_folder.path_join("copied_file")
    var source      = test_folder.path_join(sub_folders[0].path_join(files[0]))

    assert_file_does_not_exist(destination)
    assert_file_exists(source)

    Dir_Utils.copy_file(source, destination)
    assert_file_exists(destination)

    var destination_file := FileAccess.open(destination, FileAccess.READ)
    assert_eq(destination_file.get_as_text(), "content")
