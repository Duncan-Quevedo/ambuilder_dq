include(ExternalProject)

set(PARTMC_DEPS netcdff)
if (MOSAIC_SOURCE_DIR)
  set(ENABLE_MOSAIC ON)
  list(APPEND PARTMC_DEPS mosaic)
else()
  set(ENABLE_MOSAIC OFF)
endif()

# NOTE: PartMC has no install targets, so we have to do it ourselves
add_executable(partmc IMPORTED GLOBAL)
set_target_properties(partmc PROPERTIES IMPORTED_LOCATION ${PROJECT_BINARY_DIR}/bin/partmc)
set(PARTMC_REPOSITORY https://github.com/AMBRS-Project/partmc.git)
set(PARTMC_CMAKE_ARGS -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                      -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
                      -DENABLE_MOSAIC=${ENABLE_MOSAIC})
ExternalProject_Add(partmc_proj
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/partmc
                    DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}
                    SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/partmc-src
                    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/partmc-bld
                    GIT_REPOSITORY ${PARTMC_REPOSITORY}
                    GIT_TAG jeff-cohere/single-pass-linker-fix
                    DEPENDS ${PARTMC_DEPS}
                    # PartMC assumes shared libraries for NetCDF, so we replace its config here
                    PATCH_COMMAND cmake -E copy ${CMAKE_CURRENT_SOURCE_DIR}/netcdf.cmake ${CMAKE_CURRENT_BINARY_DIR}/partmc-src
                    # we have to pass NETCDF_HOME (and maybe MOSAIC_HOME) to cmake via cmake -E env below
                    CONFIGURE_COMMAND cmake -E env NETCDF_HOME=${PROJECT_BINARY_DIR} MOSAIC_HOME=${PROJECT_BINARY_DIR} cmake -S ${CMAKE_CURRENT_BINARY_DIR}/partmc-src -B ${CMAKE_CURRENT_BINARY_DIR}/partmc-bld ${PARTMC_CMAKE_ARGS}
                    LOG_CONFIGURE TRUE
                    BUILD_COMMAND make # (parallel builds have module dependency issues!)
                    INSTALL_COMMAND cmake -E copy ${CMAKE_CURRENT_BINARY_DIR}/partmc-bld/partmc ${PROJECT_BINARY_DIR}/bin
                    LOG_BUILD TRUE
                    LOG_OUTPUT_ON_FAILURE TRUE)
add_dependencies(partmc partmc_proj)
install(FILES ${PROJECT_BINARY_DIR}/bin/partmc DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
