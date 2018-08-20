## this file must be included from the root of DDS project
set(OPENDDS_SAFETY_PROFILE NO CACHE STRING "")
set_property(CACHE OPENDDS_SAFETY_PROFILE PROPERTY STRINGS NO BASE EXTENDED)
if (OPENDDS_SAFETY_PROFILE)
  list(APPEND DCPS_COMPILE_DEFINITIONS OPENDDS_SAFETY_PROFILE)
endif()

set(OPENDDS_BASE_OPTIONS
    OPENDDS_HAS_QUERY_CONDITION
    OPENDDS_HAS_CONTENT_FILTERED_TOPIC
    OPENDDS_HAS_MULTI_TOPIC
    OPENDDS_HAS_OWNERSHIP_KIND_EXCLUSIVE
    OPENDDS_HAS_OBJECT_MODEL_PROFILE
    OPENDDS_HAS_PERSISTENCE_PROFILE
)

foreach(opt ${OPENDDS_BASE_OPTIONS})
  if (OPENDDS_SAFETY_PROFILE)
    option(${opt} "" OFF)
  else()
    option(${opt} "" ON)
  endif()
endforeach()

list(APPEND OPENDDS_BASE_OPTIONS
     OPENDDS_HAS_CONTENT_SUBSCRIPTION
     OPENDDS_HAS_OWNERSHIP_PROFILE)

foreach(opt OPENDDS_HAS_BUILT_IN_TOPICS OPENDDS_HAS_CONTENT_SUBSCRIPTION OPENDDS_HAS_OWNERSHIP_PROFILE)
  option(${opt} "" ON)
endforeach()

if (NOT OPENDDS_HAS_CONTENT_SUBSCRIPTION)
  set(OPENDDS_HAS_QUERY_CONDITION OFF)
  set(OPENDDS_HAS_CONTENT_FILTERED_TOPIC OFF)
  set(OPENDDS_HAS_MULTI_TOPIC OFF)
endif()

if (NOT OPENDDS_HAS_OWNERSHIP_PROFILE)
  # Currently there is no support for exclusion of code dealing with HISTORY depth > 1
  # therefore ownership_profile is the same as ownership_kind_exclusive.
  set(OPENDDS_HAS_OWNERSHIP_KIND_EXCLUSIVE OFF)
endif()

option(OPENDDS_SUPPRESS_ANYS "" ON)
option(OPENDDS_USE_UNIQUE_PTR_EMULATION "Do not use std::unqiue_ptr even when C++11 or above is detected." OFF)


if (OPENDDS_HAS_CONTENT_SUBSCRIPTION AND (OPENDDS_HAS_QUERY_CONDITION OR OPENDDS_HAS_CONTENT_FILTERED_TOPIC OR OPENDDS_HAS_MULTI_TOPIC))
  set(OPENDDS_HAS_CONTENT_SUBSCRIPTION_CORE TRUE)
endif()

foreach(opt ${OPENDDS_BASE_OPTIONS})
  if (NOT ${opt})
    string(REPLACE OPENDDS_HAS OPENDDS_NO inverted_opt ${opt})
    list(APPEND DCPS_COMPILE_DEFINITIONS ${inverted_opt})
  endif()
endforeach()

if (OPENDDS_USE_UNIQUE_PTR_EMULATION)
  list(APPEND DCPS_COMPILE_DEFINITIONS OPENDDS_USE_UNIQUE_PTR_EMULATION)
endif(OPENDDS_USE_UNIQUE_PTR_EMULATION)

if (NOT OPENDDS_HAS_BUILT_IN_TOPICS)
  list(APPEND DCPS_COMPILE_DEFINITIONS DDS_HAS_MINIMUM_BIT)
endif()

if (OPENDDS_SAFETY_PROFILE)
  option(OPENDDS_SECURITY "" OFF)
else()
  option(OPENDDS_SECURITY "" ON)
endif()

if (OPENDDS_SECURITY)
  list(APPEND DCPS_COMPILE_DEFINITIONS OPENDDS_SECURITY)
endif()

set(DDS_OPTIONS ${DCPS_COMPILE_DEFINITIONS}
                OPENDDS_HAS_BUILT_IN_TOPICS
                OPENDDS_SUPPRESS_ANYS
                OPENDDS_USE_UNIQUE_PTR_EMULATION
                OPENDDS_SAFETY_PROFILE
                OPENDDS_HAS_CONTENT_SUBSCRIPTION_CORE
                OPENDDS_SECURITY
                DCPS_COMPILE_DEFINITIONS
                TAO_BASE_IDL_FLAGS
                DDS_BASE_IDL_FLAGS)

