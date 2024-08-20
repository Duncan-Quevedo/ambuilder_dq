include(ExternalProject)

# libraries are installed to PROJECT_BINARY_DIR, and located with
# environment variables
set(ENV{NETCDF_HOME} ${PROJECT_BINARY_DIR})
set(ENV{MOSAIC_HOME} ${PROJECT_BINARY_DIR})

add_executable(partmc IMPORTED GLOBAL)
set_target_properties(partmc PROPERTIES IMPORTED_LOCATION ${PROJECT_BINARY_DIR}/bin/partmc)
set(PARTMC_REPOSITORY https://github.com/AMBRS-Project/partmc.git)
set(PARTMC_CMAKE_OPTS -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                      -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
                      -DENABLE_MOSAIC=ON)
ExternalProject_Add(partmc_proj
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/partmc
                    DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/partmc
                    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/partmc
                    INSTALL_DIR ${PROJECT_BINARY_DIR}
                    GIT_REPOSITORY ${PARTMC_REPOSITORY}
                    DEPENDS netcdff_proj
                    CMAKE_ARGS ${PARTMC_CMAKE_OPTS}
                    LOG_CONFIGURE TRUE
                    BUILD_COMMAND make -j
                    LOG_BUILD TRUE
                    INSTALL_COMMAND make install
                    LOG_INSTALL TRUE)
install(TARGETS partmc DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
