include(ExternalProject)

# libraries are installed to PROJECT_BINARY_DIR, and located with
# environment variables
set(ENV{NETCDF_HOME} ${PROJECT_BINARY_DIR})
set(ENV{MOSAIC_HOME} ${PROJECT_BINARY_DIR}/libraries)

if (MOSAIC_SOURCE_DIR)
  set(ENABLE_MOSAIC ON)
else()
  set(ENABLE_MOSAIC OFF)
endif()

# NOTE: partmc has no install targets, so we have to do it ourselves
add_executable(partmc IMPORTED GLOBAL)
set_target_properties(partmc PROPERTIES IMPORTED_LOCATION ${CMAKE_CURRENT_BINARY_DIR}/partmc/partmc)
set(PARTMC_REPOSITORY https://github.com/AMBRS-Project/partmc.git)
set(PARTMC_CMAKE_OPTS -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                      -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
                      -DENABLE_MOSAIC=${ENABLE_MOSAIC})
ExternalProject_Add(partmc_proj
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/partmc
                    DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}
                    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/partmc-src
                    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/partmc
                    GIT_REPOSITORY ${PARTMC_REPOSITORY}
                    DEPENDS netcdff_proj
                    CMAKE_ARGS ${PARTMC_CMAKE_OPTS}
                    LOG_CONFIGURE TRUE
                    BUILD_COMMAND make
                    LOG_BUILD TRUE
                    LOG_OUTPUT_ON_FAILURE TRUE)
add_dependencies(partmc partmc_proj)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/partmc/partmc DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
