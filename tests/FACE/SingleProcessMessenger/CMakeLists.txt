ace_requires("TARGET OpenDDS_FACE")

add_subdirectory(Idl)
add_subdirectory(SingleProcess)

include(${OpenDDS_INCLUDE_DIR}/cmake/dds_add_test.cmake)
dds_configure_test_files()


dds_add_test("tests/FACE/SingleProcess/run_test.pl"
  COMMAND run_test.pl
  LABELS RTPS FACE
)
