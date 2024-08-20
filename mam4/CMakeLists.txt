include(ExternalProject)

add_executable(mam4 IMPORTED GLOBAL)
set_target_properties(mam4 PROPERTIES IMPORTED_LOCATION ${PROJECT_BINARY_DIR}/bin/mam4)
set(MAM4_REPOSITORY https://github.com/AMBRS-Project/MAM_box_model.git)
set(MAM4_CMAKE_OPTS -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
                    -DLIBRARIES_DIR=${PROJECT_BINARY_DIR})
ExternalProject_Add(mam4_proj
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/mam4
                    DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/mam4
                    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/mam4
                    INSTALL_DIR ${PROJECT_BINARY_DIR}
                    GIT_REPOSITORY ${MAM4_REPOSITORY}
                    PATCH_COMMAND cmake -E copy CMakeLists_mam4.txt ${CMAKE_CURRENT_SOURCE_DIR}/mam4
                    CMAKE_ARGS ${MAM4_CMAKE_OPTS}
                    LOG_CONFIGURE TRUE
                    BUILD_COMMAND make -j
                    LOG_BUILD TRUE
                    INSTALL_COMMAND make install
                    LOG_INSTALL TRUE)
install(TARGETS mam4 DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
