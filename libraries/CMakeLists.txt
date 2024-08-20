include(ExternalProject)
include_directories(${PROJECT_BINARY_DIR}/include)

# Create canonical top-level directories in the build directory.
foreach(dir include;lib;bin;share)
  set(top_level_dir ${PROJECT_BINARY_DIR}/${dir})
  if (NOT EXISTS ${top_level_dir})
    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${top_level_dir})
  endif()
endforeach()

# zlib -- file compression
add_library(z STATIC IMPORTED GLOBAL)
set_target_properties(z PROPERTIES IMPORTED_LOCATION ${PROJECT_BINARY_DIR}/lib/libz.a)
set(ZLIB_VERSION 1.3.1)
set(ZLIB_DOWNLOAD_URL https://github.com/madler/zlib/archive/refs/tags/v${ZLIB_VERSION}.zip)
set(ZLIB_CONFIG_OPTS --prefix=${PROJECT_BINARY_DIR} --static)
ExternalProject_Add(zlib_proj
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zlib
                    DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/zlib
                    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib
                    INSTALL_DIR ${PROJECT_BINARY_DIR}
                    URL ${ZLIB_DOWNLOAD_URL}
                    CONFIGURE_COMMAND env CC=${CMAKE_C_COMPILER} CFLAGS=${CMAKE_C_FLAGS} ${CMAKE_CURRENT_SOURCE_DIR}/zlib/configure ${ZLIB_CONFIG_OPTS}
                    LOG_CONFIGURE TRUE
                    BUILD_COMMAND make -j
                    LOG_BUILD TRUE
                    INSTALL_COMMAND make install
                    LOG_INSTALL TRUE)

# HDF5 parallel I/O library (needed for NetCDF4)
add_library(hdf5 STATIC IMPORTED GLOBAL)
add_library(hdf5_hl STATIC IMPORTED GLOBAL)
set_target_properties(hdf5 PROPERTIES IMPORTED_LOCATION ${PROJECT_BINARY_DIR}/lib/libhdf5.a)
set_target_properties(hdf5_hl PROPERTIES IMPORTED_LOCATION ${PROJECT_BINARY_DIR}/lib/libhdf5_hl.a)
set(HDF5_VERSION 1.14.4.3)
set(HDF5_DOWNLOAD_URL  https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_${HDF5_VERSION}.zip)
set(HDF5_CONFIG_OPTS --prefix=${PROJECT_BINARY_DIR} --disable-shared
    --with-zlib=${PROJECT_BINARY_DIR}/include,${PROJECT_BINARY_DIR}/lib
    --enable-build-mode=production
    --disable-fortran --disable-cxx --disable-java --disable-tools
    --disable-tests)
ExternalProject_Add(hdf5_proj
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/hdf5
                    DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/hdf5
                    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/hdf5
                    INSTALL_DIR ${PROJECT_BINARY_DIR}
                    URL ${HDF5_DOWNLOAD_URL}
                    CONFIGURE_COMMAND env CC=${CMAKE_C_COMPILER} CFLAGS=${CMAKE_C_FLAGS} ${CMAKE_CURRENT_SOURCE_DIR}/hdf5/configure ${HDF5_CONFIG_OPTS}
                    DEPENDS zlib_proj
                    LOG_CONFIGURE TRUE
                    BUILD_COMMAND make -j
                    LOG_BUILD TRUE
                    INSTALL_COMMAND make install
                    LOG_INSTALL TRUE)
add_dependencies(hdf5 hdf5_proj)

# NetCDF C library
add_library(netcdf STATIC IMPORTED GLOBAL)
set_target_properties(netcdf PROPERTIES IMPORTED_LOCATION ${PROJECT_BINARY_DIR}/lib/libnetcdf.a)
set(NETCDF_VERSION 4.9.2)
set(NETCDF_DOWNLOAD_URL https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDF_VERSION}.zip)
set(NETCDF_CONFIG_OPTS --prefix=${PROJECT_BINARY_DIR} --disable-shared
    --enable-netcdf4 --disable-dap --disable-testsets --disable-examples)
# HDF5 headers should be given in CPPFLAGS, but the NetCDF folks aren't very
# careful about this stuff.
set(NETCDF_C_FLAGS "${CMAKE_C_FLAGS} -I${HDF5_INCLUDE_DIR}")
ExternalProject_Add(netcdf_proj
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/netcdf-c
                    DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/netcdf-c
                    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/netcdf-c
                    INSTALL_DIR ${PROJECT_BINARY_DIR}
                    URL ${NETCDF_DOWNLOAD_URL}
                    DEPENDS hdf5
                    CONFIGURE_COMMAND env CC=${CMAKE_C_COMPILER} CFLAGS=${NETCDF_C_FLAGS} LDFLAGS=-L${HDF5_LIBRARY_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/netcdf-c/configure ${NETCDF_CONFIG_OPTS}
                    LOG_CONFIGURE TRUE
                    BUILD_COMMAND make -j
                    LOG_BUILD TRUE
                    INSTALL_COMMAND make install
                    LOG_INSTALL TRUE)
add_dependencies(netcdf netcdf_proj)

# NetCDF Fortran library
add_library(netcdff STATIC IMPORTED GLOBAL)
set_target_properties(netcdff PROPERTIES IMPORTED_LOCATION ${PROJECT_BINARY_DIR}/lib/libnetcdff.a)
set(NETCDFF_VERSION 4.6.1)
set(NETCDFF_DOWNLOAD_URL https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDFF_VERSION}.zip)
set(NETCDFF_CONFIG_OPTS --prefix=${PROJECT_BINARY_DIR})
ExternalProject_Add(netcdff_proj
                    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/netcdf-fortran
                    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/netcdf-fortran
                    BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/netcdf-fortran
                    INSTALL_DIR ${PROJECT_BINARY_DIR}
                    DEPENDS netcdf
                    CONFIGURE_COMMAND env CC=${CMAKE_C_COMPILER} FC=${CMAKE_Fortran_COMPILER} CFLAGS=${CMAKE_C_FLAGS} FCFLAGS=${CMAKE_Fortran_FLAGS} CPPFLAGS=-I${NETCDF_INCLUDE_DIR} LDFLAGS=-L${NETCDF_LIBRARY_DIR} LIBS=${NETCDFF_LIBS} ${CMAKE_CURRENT_SOURCE_DIR}/netcdf-fortran/configure ${NETCDFF_CONFIG_OPTS}
                    LOG_CONFIGURE TRUE
                    BUILD_COMMAND make -j
                    LOG_BUILD TRUE
                    INSTALL_COMMAND make install
                    LOG_INSTALL TRUE)
add_dependencies(netcdff netcdff_proj)

# Mosaic (if available)
if (MOSAIC_SOURCE_DIR)
  add_library(mosaic STATIC
    ${MOSAIC_SOURCE_DIR}/datamodules/module_data_mosaic_main.f90
    ${MOSAIC_SOURCE_DIR}/datamodules/module_data_mosaic_aero.f90
    ${MOSAIC_SOURCE_DIR}/datamodules/module_data_mosaic_gas.f90
    ${MOSAIC_SOURCE_DIR}/datamodules/module_data_mosaic_cloud.f90
    ${MOSAIC_SOURCE_DIR}/datamodules/module_data_mosaic_kind.f90

    ${MOSAIC_SOURCE_DIR}/aerosol/aerchemistry.f90
    ${MOSAIC_SOURCE_DIR}/aerosol/aeroptical.f90
    ${MOSAIC_SOURCE_DIR}/aerosol/miedriver.f90
    ${MOSAIC_SOURCE_DIR}/aerosol/ASTEM.f90
    ${MOSAIC_SOURCE_DIR}/aerosol/cputime.f90
    ${MOSAIC_SOURCE_DIR}/aerosol/mosaic_box.21.f90

    ${MOSAIC_SOURCE_DIR}/cloud/cldchemistry.f90

    ${MOSAIC_SOURCE_DIR}/gas/function_arr.f90
    ${MOSAIC_SOURCE_DIR}/gas/function_troe.f90
    ${MOSAIC_SOURCE_DIR}/gas/gaschemistry.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasintegrator.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrateconstants_bio.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrateconstants_com.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrateconstants.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrateconstants_het.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrateconstants_mar.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrateconstants_urb.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrates_bio.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrates_com.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrates.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrates_het.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrates_mar.f90
    ${MOSAIC_SOURCE_DIR}/gas/gasrates_urb.f90
    ${MOSAIC_SOURCE_DIR}/gas/jac.f90
    ${MOSAIC_SOURCE_DIR}/gas/loadperoxyparameters.f90
    ${MOSAIC_SOURCE_DIR}/gas/mapgas_bio.f90
    ${MOSAIC_SOURCE_DIR}/gas/mapgas_com.f90
    ${MOSAIC_SOURCE_DIR}/gas/mapgas_mar.f90
    ${MOSAIC_SOURCE_DIR}/gas/mapgasspecies.f90
    ${MOSAIC_SOURCE_DIR}/gas/mapgas_urb.f90
    ${MOSAIC_SOURCE_DIR}/gas/ode_bio.f90
    ${MOSAIC_SOURCE_DIR}/gas/ode_com.f90
    ${MOSAIC_SOURCE_DIR}/gas/ode_gas.f90
    ${MOSAIC_SOURCE_DIR}/gas/ode_het.f90
    ${MOSAIC_SOURCE_DIR}/gas/ode_mar.f90
    ${MOSAIC_SOURCE_DIR}/gas/ode_urb.f90
    ${MOSAIC_SOURCE_DIR}/gas/peroxyrateconstants.f90
    ${MOSAIC_SOURCE_DIR}/gas/photoconstants_fixed.f90
    ${MOSAIC_SOURCE_DIR}/gas/photoconstants_solar.f90
    ${MOSAIC_SOURCE_DIR}/gas/photoparam1.f90
    ${MOSAIC_SOURCE_DIR}/gas/photoparam2.f90
    ${MOSAIC_SOURCE_DIR}/gas/selectgasregime.f90
    ${MOSAIC_SOURCE_DIR}/gas/setgas_bio.f90
    ${MOSAIC_SOURCE_DIR}/gas/setgas_com.f90
    ${MOSAIC_SOURCE_DIR}/gas/setgasindices.f90
    ${MOSAIC_SOURCE_DIR}/gas/setgas_mar.f90
    ${MOSAIC_SOURCE_DIR}/gas/setgas_urb.f90
    ${MOSAIC_SOURCE_DIR}/gas/solarzenithangle.f90

    ${MOSAIC_SOURCE_DIR}/solver/dlsode.f90
  )
  set_target_properties(mosaic PROPERTIES INCLUDE_DIRECTORIES ${MOSAIC_SOURCE_DIR}/datamodules)
endif()
