set(DCPS_CXX_COMPILE_DEFINITIONS ${DCPS_COMPILE_DEFINITIONS})

if (NOT OPENDDS_SAFETY_PROFILE)
  set(dcps_link_libraries TAO_PortableServer TAO_BiDirGIOP)
else()
  set(dcps_link_libraries OpenDDS_Corba)
  list(APPEND DCPS_CXX_COMPILE_DEFINITIONS TAOLIB_ERROR=ACELIB_ERROR TAOLIB_DEBUG=ACELIB_DEBUG)
  add_subdirectory(CORBA)
endif()

if (MSVC)
  list(APPEND DCPS_CXX_COMPILE_DEFINITIONS _SCL_SECURE_NO_WARNINGS)
endif(MSVC)

ace_add_lib(OpenDDS_Dcps
  PACKAGE OpenDDS
  FOLDER OpenDDS/dds
  DEFINE_SYMBOL OPENDDS_DCPS_BUILD_DLL
  PRECOMPILED_HEADER DCPS/DdsDcps_pch.h
  PUBLIC_COMPILE_DEFINITIONS "${DCPS_CXX_COMPILE_DEFINITIONS}"
  PUBLIC_INCLUDE_DIRECTORIES $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
                             $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/..>
                             $<INSTALL_INTERFACE:${OpenDDS_INSTALL_DIR}>
  PUBLIC_LINK_LIBRARIES "${dcps_link_libraries}"
)

ace_target_cxx_sources(OpenDDS_Dcps
  HEADER_FILES Version.h
               Versioned_Namespace.h
               DCPS/yard
)

# flags used by all directories under $DDS_ROOT/dds
list(APPEND TAO_BASE_IDL_FLAGS
  -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL
  -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL
  -Wb,versioning_include=dds/Versioned_Namespace.h
)

list(APPEND DDS_BASE_IDL_FLAGS
  -Wb,versioning_begin=OPENDDS_BEGIN_VERSIONED_NAMESPACE_DECL
  -Wb,versioning_end=OPENDDS_END_VERSIONED_NAMESPACE_DECL
  -Wb,versioning_name=OPENDDS_VERSIONED_NAMESPACE_NAME
)

include(dcps_optional_safety.cmake)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/CorbaSeq)
include(CorbaSeq/CMakeLists.txt)
include(DCPS/CMakeLists.txt)
include(DCPS/transport/framework/CMakeLists.txt)
include(DCPS/security/framework/CMakeLists.txt)
