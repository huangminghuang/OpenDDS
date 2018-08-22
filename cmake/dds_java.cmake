include(UseJava)

define_property(SOURCE PROPERTY IDL2JNI_FLAGS
  BRIEF_DOCS "sets additional idl2jni compiler flags used to build sources within the target"
  FULL_DOCS "sets additional idl2jni compiler flags used to build sources within the target"
)

if (NOT OPENDDS_HAS_BUILT_IN_TOPICS)
  list(APPEND BASE_IDL2JNI_FLAGS -DDDS_HAS_MINIMUM_BIT)
endif()

if (NOT OPENDDS_HAS_CONTENT_SUBSCRIPTION)
  list(APPEND BASE_IDL2JNI_FLAGS -DOPENDDS_NO_QUERY_CONDITION
                                 -DOPENDDS_NO_CONTENT_FILTERED_TOPIC
                                 -DOPENDDS_NO_MULTI_TOPIC)
endif()

if (NOT OPENDDS_HAS_QUERY_CONDITION)
  list(APPEND BASE_IDL2JNI_FLAGS  -DOPENDDS_NO_QUERY_CONDITION)
endif()

if (NOT OPENDDS_HAS_CONTENT_FILTERED_TOPIC)
  list(APPEND BASE_IDL2JNI_FLAGS -DOPENDDS_NO_CONTENT_FILTERED_TOPIC)
endif()

if (NOT OPENDDS_HAS_MULTI_TOPIC)
  list(APPEND BASE_IDL2JNI_FLAGS -DOPENDDS_NO_MULTI_TOPIC)
endif()

if (NOT OPENDDS_HAS_OWNERSHIP_PROFILE)
  list(APPEND BASE_IDL2JNI_FLAGS -DOPENDDS_NO_OWNERSHIP_PROFILE
                                 -DOPENDDS_NO_OWNERSHIP_KIND_EXCLUSIVE)
endif()

if (NOT OPENDDS_HAS_OWNERSHIP_KIND_EXCLUSIVE)
  list(APPEND BASE_IDL2JNI_FLAGS -DOPENDDS_NO_OWNERSHIP_KIND_EXCLUSIVE)
endif()

if (NOT OPENDDS_HAS_OBJECT_MODEL_PROFILE)
  list(APPEND BASE_IDL2JNI_FLAGS -DOPENDDS_NO_OBJECT_MODEL_PROFILE)
endif()

if (NOT OPENDDS_HAS_PERSISTENCE_PROFILE)
  list(APPEND BASE_IDL2JNI_FLAGS -DOPENDDS_NO_PERSISTENCE_PROFILE)
endif()


function(dds_idl2jni_command name)
  ### Warning, all filename in IDL_FILES must be absolute
  set(multiValueArgs FLAGS IDL_FILES DEPENDS)
  cmake_parse_arguments(_arg "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(all_cxx_outputs)
  set(all_java_lists)


  foreach(file ${_arg_IDL_FILES})
    get_filename_component(basename ${file} NAME_WE)
    get_filename_component(filename_no_dir ${file} NAME)
    get_filename_component(abs_filename ${file} ABSOLUTE)
    file(TO_NATIVE_PATH ${abs_filename} abs_native_filename)
    set(cxx_outputs ${basename}JC.h ${basename}JC.cpp)

    get_property(file_idl2jni_flags SOURCE ${file} PROPERTY IDL2JNI_FLAGS)
    list(APPEND file_idl2jni_flags ${_arg_FLAGS})

    if (NOT "-SS" IN_LIST file_idl2jni_flags)
      list(APPEND cxx_outputs ${basename}JS.h ${basename}JS.cpp)
    endif()
    list(APPEND all_cxx_outputs ${cxx_outputs})

    list(APPEND all_java_lists @${CMAKE_CURRENT_BINARY_DIR}/${filename_no_dir}.java.list)

    if (IDL_PATH_ENV)
      set(idl2jni_cmd ${CMAKE_COMMAND} -E env "${IDL_PATH_ENV}" $<TARGET_FILE:idl2jni>)
    else()
      set(idl2jni_cmd idl2jni)
    endif()

    add_custom_command(
      OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${filename_no_dir}.java.list ${cxx_outputs}
      COMMAND ${idl2jni_cmd} -j ${BASE_IDL2JNI_FLAGS} -I${CMAKE_CURRENT_SOURCE_DIR} ${file_idl2jni_flags} ${abs_native_filename}
      DEPENDS idl2jni ${abs_filename} ${_arg_DEPENDS}
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
  endforeach()
  source_group("Generated Files" FILES ${all_java_lists})

  set(${name}_CXX_OUTPUTS ${${name}_CXX_OUTPUTS} ${all_cxx_outputs})
  set(${name}_JAVA_OUTPUTS ${${name}_JAVA_OUTPUTS} ${all_java_lists})

  set(${name}_CXX_OUTPUTS ${${name}_CXX_OUTPUTS} PARENT_SCOPE)
  set(${name}_JAVA_OUTPUTS ${${name}_JAVA_OUTPUTS} PARENT_SCOPE)
endfunction()


function(dds_add_jar _target_name)
  set(oneValueArgs OUTPUT_NAME VERSION OUTPUT_DIR FOLDER ENTRY_POINT GENERATE_NATIVE_HEADERS DESTINATION)
  set(multiValueArgs INCLUDE_JARS SOURCES)
  cmake_parse_arguments(_arg "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (_arg_ENTRY_POINT)
    set(forward_args ENTRY_POINT ${_arg_ENTRY_POINT})
  endif()
  
  if (_arg_GENERATE_NATIVE_HEADERS)
    set(forward_args ${forward_args} GENERATE_NATIVE_HEADERS ${_arg_GENERATE_NATIVE_HEADERS})
    if (_arg_DESTINATION) 
      set(forward_args ${forward_args} DESTINATION ${_arg_DESTINATION})
    endif(_arg_DESTINATION)
  endif(_arg_GENERATE_NATIVE_HEADERS)

  add_jar(${_target_name}
    OUTPUT_NAME "${_arg_OUTPUT_NAME}"
    OUTPUT_DIR "${_arg_OUTPUT_DIR}"
    VERSION ${_arg_VERSION}
    INCLUDE_JARS ${_arg_INCLUDE_JARS}
    SOURCES ${_arg_SOURCES}
    ${forward_args}
  )

  if (NOT _arg_FOLDER AND ACEUTIL_TOP_LEVEL_FOLDER_DIR AND ACEUTIL_TOP_LEVEL_FOLDER_NAME)
    file(RELATIVE_PATH folder ${ACEUTIL_TOP_LEVEL_FOLDER_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
    set(_arg_FOLDER ${ACEUTIL_TOP_LEVEL_FOLDER_NAME}/${folder})
  endif()

  if (DEFINED _arg_FOLDER)
    set_target_properties(${_target_name} PROPERTIES FOLDER ${_arg_FOLDER})
  endif()

  if (_arg_OUTPUT_DIR AND NOT EXISTS "${_arg_OUTPUT_DIR}/CMakeFiles/${_target_name}.dir")
    file(MAKE_DIRECTORY "${_arg_OUTPUT_DIR}/CMakeFiles/${_target_name}.dir")
  endif()

endfunction()

function(dds_add_taoidl_jar _target_name)
  set(oneValueArgs OUTPUT_NAME VERSION LIB OUTPUT_DIR FOLDER)
  set(multiValueArgs TAO_IDL_FLAGS IDL2JNI_FLAGS IDL_FILES INCLUDE_JARS SOURCES)
  cmake_parse_arguments(_arg "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT DEFINED _arg_OUTPUT_NAME)
    set(_arg_OUTPUT_NAME ${_target_name})
  endif()

  if (NOT DEFINED _arg_OUTPUT_DIR)
    set(_arg_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()

  if (NOT (TARGET ${_arg_LIB} AND TARGET TAO_PortableServer))
    return()
  endif()

  target_link_libraries(${_arg_LIB} PUBLIC
    idl2jni_runtime TAO_PortableServer)

  tao_idl_sources(
    TARGETS ${_arg_LIB}
    IDL_FLAGS ${_arg_TAO_IDL_FLAGS}
    IDL_FILES ${_arg_IDL_FILES}
  )

  set(CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON PARENT_SCOPE)
  set(CMAKE_INCLUDE_CURRENT_DIR ON PARENT_SCOPE)

  get_target_property(libname ${_arg_LIB} OUTPUT_NAME)
  if (NOT libname)
    set(libname ${_arg_LIB})
  endif()

  dds_idl2jni_command(${_target_name}_idl2jni
    FLAGS -Wb,native_lib_name=${libname} ${_arg_IDL2JNI_FLAGS}
    IDL_FILES ${_arg_IDL_FILES}
  )

  if (${_target_name}_idl2jni_CXX_OUTPUTS)
    ace_target_sources(${_arg_LIB} PRIVATE
      ${${_target_name}_idl2jni_CXX_OUTPUTS}
    )
  endif()

  dds_add_jar(${_target_name}
    OUTPUT_NAME "${_arg_OUTPUT_NAME}"
    OUTPUT_DIR "${_arg_OUTPUT_DIR}"
    VERSION ${_arg_VERSION}
    INCLUDE_JARS i2jrt ${_arg_INCLUDE_JARS}
    SOURCES ${${_target_name}_idl2jni_JAVA_OUTPUTS} ${_arg_SOURCES}
  )
endfunction()

function(dds_add_ddsidl_jar _target_name)
  set(oneValueArgs OUTPUT_NAME VERSION LIB OUTPUT_DIR FOLDER)
  set(multiValueArgs TAO_IDL_FLAGS DDS_IDL_FLAGS IDL2JNI_FLAGS IDL_FILES INCLUDE_JARS SOURCES)
  cmake_parse_arguments(_arg "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if (NOT DEFINED _arg_OUTPUT_NAME)
    set(_arg_OUTPUT_NAME ${_target_name})
  endif()

  if (NOT DEFINED _arg_OUTPUT_DIR)
    set(_arg_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR})
  endif()

  if (_arg_VERSION)
    set(version_option VERSION ${_arg_VERSION})
  endif()

  if (NOT (TARGET ${_arg_LIB} AND TARGET OpenDDS_DCPS_Java))
    return()
  endif()

  target_link_libraries(${_arg_LIB} PUBLIC
    OpenDDS_DCPS_Java
  )

  dds_idl_sources(
    TARGETS ${_arg_LIB}
    TAO_IDL_FLAGS ${_arg_TAO_IDL_FLAGS}
    DDS_IDL_FLAGS -Wb,java ${_arg_DDS_IDL_FLAGS}
    IDL_FILES ${_arg_IDL_FILES}
  )

  set(CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON PARENT_SCOPE)
  set(CMAKE_INCLUDE_CURRENT_DIR ON PARENT_SCOPE)

  get_target_property(libname ${_arg_LIB} OUTPUT_NAME)
  if (NOT libname)
    set(libname ${_arg_LIB})
  endif()

  dds_idl2jni_command(${_target_name}_idl2jni
    FLAGS -Wb,native_lib_name=${libname} -SS -I${OpenDDS_INCLUDE_DIR} -I${TAO_INCLUDE_DIR} ${_arg_IDL2JNI_FLAGS}
    IDL_FILES ${_arg_IDL_FILES} ${DDS_IDL_TYPESUPPORT_IDLS}
  )

  if (${_target_name}_idl2jni_CXX_OUTPUTS)
    ace_target_sources(${_arg_LIB} PRIVATE
      ${${_target_name}_idl2jni_CXX_OUTPUTS}
    )
  endif()

  dds_add_jar(${_target_name}
    OUTPUT_NAME "${_arg_OUTPUT_NAME}"
    OUTPUT_DIR "${_arg_OUTPUT_DIR}"
    ${version_option}
    INCLUDE_JARS i2jrt OpenDDS_DCPS_jar  ${_arg_INCLUDE_JARS}
    SOURCES ${${_target_name}_idl2jni_JAVA_OUTPUTS} ${_arg_SOURCES} ${DDS_IDL_JAVA_OUTPUTS}
  )
endfunction()