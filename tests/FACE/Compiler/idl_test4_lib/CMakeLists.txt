
if (CMAKE_SYSTEM_NAME STREQUAL "Android")
  set(no_test_wstring_flag -DNO_TEST_WSTRING)
  set(no_test_wstring_def NO_TEST_WSTRING)
endif()

set(CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON)
ace_add_lib(FACE_idl_test4_lib
  OUTPUT_NAME FACE_idl_test4_lib
  PUBLIC_LINK_LIBRARIES OpenDDS_FACE
  PUBLIC_COMPILE_DEFINITIONS "${no_test_wstring_def}"
)
dds_idl_sources(
  TARGETS FACE_idl_test4_lib
  DDS_IDL_FLAGS ${no_test_wstring_flag}
  IDL_FILES top.idl
            typedef_only.idl
            struct_only.idl
)
