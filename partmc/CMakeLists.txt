include(ExternalProject)

set(PARTMC_DEPS camp;netcdff)

# NOTE: PartMC has no install targets, so we have to do it ourselves
add_executable(partmc IMPORTED GLOBAL)
set_target_properties(partmc PROPERTIES IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/bin/partmc)
set(PARTMC_DOWNLOAD_URL https://github.com/AMBRS-Project/partmc/archive/refs/heads/master.zip)
set(PARTMC_MD5 88c1023d440a3ee113fd7908f193a9a4)
set(PARTMC_CMAKE_ARGS
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
  -DENABLE_CAMP=ON
)
ExternalProject_Add(partmc_proj
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/partmc
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/downloads
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/partmc-src
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/partmc-bld
  URL ${PARTMC_DOWNLOAD_URL}
  URL_MD5 ${PARTMC_MD5}
  DEPENDS ${PARTMC_DEPS}
  UPDATE_COMMAND ""
  # PartMC assumes shared libraries for NetCDF, so we replace its config here
  PATCH_COMMAND cmake -E copy ${CMAKE_CURRENT_SOURCE_DIR}/netcdf.cmake ${CMAKE_CURRENT_BINARY_DIR}/partmc-src
  # we have to pass NETCDF_HOME and CAMP_HOME to cmake via cmake -E env below
  CONFIGURE_COMMAND cmake -E env NETCDF_HOME=${CMAKE_BINARY_DIR} CAMP_HOME=${CMAKE_BINARY_DIR} cmake -S ${CMAKE_CURRENT_BINARY_DIR}/partmc-src -B ${CMAKE_CURRENT_BINARY_DIR}/partmc-bld ${PARTMC_CMAKE_ARGS}
  LOG_CONFIGURE TRUE
  BUILD_COMMAND make # (parallel builds have module dependency issues!)
  INSTALL_COMMAND cmake -E copy ${CMAKE_CURRENT_BINARY_DIR}/partmc-bld/partmc ${CMAKE_BINARY_DIR}/bin
  LOG_BUILD TRUE
  LOG_OUTPUT_ON_FAILURE TRUE
)
add_dependencies(partmc partmc_proj)
install(
  PROGRAMS ${CMAKE_CURRENT_BINARY_DIR}/partmc-bld/partmc
  DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
)
