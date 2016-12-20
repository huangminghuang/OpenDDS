set(CMAKE_INCLUDE_CURRENT_DIR ON)
ace_add_exe(FaceMessengerSingleProcess
  OUTPUT_NAME singleprocess

  INCLUDE_DIRECTORIES ${CMAKE_CURRENT_SOURCE_DIR}/../
                      ${CMAKE_CURRENT_BINARY_DIR}/../
  LINK_LIBRARIES FaceMessengerSingleProcessIdl
                 OpenDDS_FACE
                 OpenDDS_Rtps_Udp
)
ace_target_cxx_sources(FaceMessengerSingleProcess
  SOURCE_FILES SingleProcess.cpp
)

