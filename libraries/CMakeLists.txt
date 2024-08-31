include(ExternalProject)
include_directories(${CMAKE_BINARY_DIR}/include)

# Create canonical top-level directories in the build directory.
foreach(dir include;lib;bin;share)
  set(top_level_dir ${CMAKE_BINARY_DIR}/${dir})
  if (NOT EXISTS ${top_level_dir})
    execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${top_level_dir})
  endif()
endforeach()

# zlib -- file compression
add_library(z STATIC IMPORTED GLOBAL)
set_target_properties(z PROPERTIES IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/lib/libz.a)
set(ZLIB_VERSION 1.3.1)
set(ZLIB_DOWNLOAD_URL https://github.com/madler/zlib/archive/refs/tags/v${ZLIB_VERSION}.zip)
set(ZLIB_MD5 127b8a71a3fb8bebe89df1080f15fdf6)
set(ZLIB_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
  -DCMAKE_BUILD_TYPE=Release
  -DBUILD_SHARED_LIBS=OFF
)
ExternalProject_Add(zlib_proj
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/zlib
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/downloads
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib-src
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/zlib-bld
  INSTALL_DIR ${CMAKE_BINARY_DIR}
  URL ${ZLIB_DOWNLOAD_URL}
  URL_MD5 ${ZLIB_MD5}
  CMAKE_ARGS ${ZLIB_CMAKE_ARGS}
  LOG_CONFIGURE TRUE
  BUILD_COMMAND make -j
  LOG_BUILD TRUE
  INSTALL_COMMAND make install
  LOG_INSTALL TRUE
  LOG_OUTPUT_ON_FAILURE TRUE
)

# HDF5 parallel I/O library (needed for NetCDF4)
add_library(hdf5 STATIC IMPORTED GLOBAL)
add_library(hdf5_hl STATIC IMPORTED GLOBAL)
set(HDF5_LIBRARY ${CMAKE_BINARY_DIR}/lib/libhdf5.a)
set(HDF5_HL_LIBRARY ${CMAKE_BINARY_DIR}/lib/libhdf5_hl.a)
set_target_properties(hdf5 PROPERTIES IMPORTED_LOCATION ${HDF5_LIBRARY})
set_target_properties(hdf5_hl PROPERTIES IMPORTED_LOCATION ${HDF5_HL_LIBRARY})
set(HDF5_VERSION 1.14.4.3)
set(HDF5_DOWNLOAD_URL https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_${HDF5_VERSION}.zip)
set(HDF5_MD5 bc987d22e787290127aacd7b99b4f31e)
set(HDF5_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
  -DCMAKE_BUILD_TYPE=Release
  -DBUILD_SHARED_LIBS=OFF
  -DHDF5_ENABLE_PARALLEL=OFF
  -DHDF5_BUILD_CPP_LIB=OFF
  -DHDF5_BUILD_EXAMPLES=OFF
  -DHDF5_BUILD_FORTRAN=OFF
  -DHDF5_BUILD_HL_LIB=ON
  -DHDF5_BUILD_JAVA=OFF
  -DHDF5_BUILD_TOOLS=OFF
)
ExternalProject_Add(hdf5_proj
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/hdf5
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/downloads
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/hdf5-src
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/hdf5-bld
  INSTALL_DIR ${CMAKE_BINARY_DIR}
  URL ${HDF5_DOWNLOAD_URL}
  URL_MD5 ${HDF5_MD5}
  CMAKE_ARGS ${HDF5_CMAKE_ARGS}
  DEPENDS zlib_proj
  LOG_CONFIGURE TRUE
  BUILD_COMMAND make -j
  LOG_BUILD TRUE
  INSTALL_COMMAND make install
  LOG_INSTALL TRUE
  LOG_OUTPUT_ON_FAILURE TRUE
)
add_dependencies(hdf5 hdf5_proj)

# NetCDF C library
add_library(netcdf STATIC IMPORTED GLOBAL)
set(NETCDF_C_LIBRARY ${CMAKE_BINARY_DIR}/lib/libnetcdf.a)
set_target_properties(netcdf PROPERTIES IMPORTED_LOCATION ${NETCDF_C_LIBRARY})
set(NETCDF_VERSION 4.9.2)
set(NETCDF_DOWNLOAD_URL https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDF_VERSION}.zip)
set(NETCDF_MD5 d014d8eff2164d2405f3cb2ee6317e4a)
set(NETCDF_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
  -DCMAKE_BUILD_TYPE=Release
  -DBUILD_SHARED_LIBS=OFF
  -DBUILD_UTILITIES=OFF
  -DENABLE_BYTERANGE=OFF
  -DENABLE_CDF5=OFF
  -DENABLE_DAP=OFF
  -DENABLE_EXAMPLES=OFF
  -DENABLE_HDF5=ON
  -DENABLE_LIBXML=OFF
  -DENABLE_MMAP=OFF
  -DENABLE_NCZARR=OFF
  -DENABLE_NETCDF4=ON
  -DENABLE_PARALLEL4=OFF
  -DENABLE_PARALLEL_TESTS=OFF
  -DENABLE_PLUGINS=OFF
  -DENABLE_PNETCDF=OFF
  -DENABLE_TESTS=OFF
  -DHDF5_C_LIBRARY=${HDF5_LIBRARY}
  -DHDF5_HL_LIBRARY=${HDF5_HL_LIBRARY}
  -DHDF5_INCLUDE_DIR=${CMAKE_BINARY_DIR}/include
)
ExternalProject_Add(netcdf_proj
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/netcdf-c
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/downloads
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/netcdf-c-src
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/netcdf-c-bld
  INSTALL_DIR ${CMAKE_BINARY_DIR}
  URL ${NETCDF_DOWNLOAD_URL}
  URL_MD5 ${NETCDF_MD5}
  DEPENDS hdf5
  CMAKE_ARGS ${NETCDF_CMAKE_ARGS}
  LOG_CONFIGURE TRUE
  BUILD_COMMAND make -j
  LOG_BUILD TRUE
  INSTALL_COMMAND make install
  LOG_INSTALL TRUE
  LOG_OUTPUT_ON_FAILURE TRUE)
add_dependencies(netcdf netcdf_proj)

# NetCDF Fortran library
add_library(netcdff STATIC IMPORTED GLOBAL)
set_target_properties(netcdff PROPERTIES IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/lib/libnetcdff.a)
set(NETCDFF_VERSION 4.6.1)
set(NETCDFF_DOWNLOAD_URL https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v${NETCDFF_VERSION}.zip)
set(NETCDFF_MD5 779dd836a4f5461a529ad6d5521a2422)
set(NETCDFF_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib
  -DCMAKE_Fortran_FLAGS=${CMAKE_Fortran_FLAGS}
  -DBUILD_SHARED_LIBS=OFF
  -DNETCDF_C_LIBRARY=${NETCDF_C_LIBRARY}
  -DNETCDF_C_INCLUDE_DIR=${CMAKE_BINARY_DIR}/include
  -DBUILD_EXAMPLES=OFF
  -DENABLE_TESTS=OFF
  -DENABLE_FORTRAN_TYPE_CHECKS=OFF
  -DENABLE_FILTER_TESTING=OFF
)
# Because netcdf-fortran's CMake installation is broken, we need to set an
# environment variable here (https://github.com/Unidata/netcdf-fortran/issues/278#issuecomment-1939307217)
#set(ENV{LDFLAGS} "-L${CMAKE_BINARY_DIR}/lib -lnetcdf")
ExternalProject_Add(netcdff_proj
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/netcdf-fortran
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/downloads
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/netcdf-fortran-src
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/netcdf-fortran-bld
  INSTALL_DIR ${CMAKE_BINARY_DIR}
  URL ${NETCDFF_DOWNLOAD_URL}
  URL_MD5 ${NETCDFF_MD5}
  DEPENDS netcdf
  # we need to replace the CMakeLists.txt file here because the default one is broken
  # (see https://github.com/Unidata/netcdf-fortran/issues/278 for details)
  PATCH_COMMAND cmake -E copy ${CMAKE_CURRENT_SOURCE_DIR}/netcdf-fortran-CMakeLists.txt ${CMAKE_CURRENT_BINARY_DIR}/netcdf-fortran-src/CMakeLists.txt
  CMAKE_ARGS ${NETCDFF_CMAKE_ARGS}
  LOG_CONFIGURE TRUE
  BUILD_COMMAND make -j
  LOG_BUILD TRUE
  INSTALL_COMMAND make install
  LOG_INSTALL TRUE
  LOG_OUTPUT_ON_FAILURE TRUE
)
add_dependencies(netcdff netcdff_proj)
unset(ENV{LDFLAGS})

# json-fortran (for CAMP)
add_library(json-fortran STATIC IMPORTED GLOBAL)
set_target_properties(json-fortran PROPERTIES IMPORTED_LOCATION ${CMAKE_BINARY_DIR}/lib/libjsonfortran.a)
set(JSON_FORTRAN_DOWNLOAD_URL https://github.com/jacobwilliams/json-fortran/archive/6.1.0.tar.gz)
set(JSON_FORTRAN_MD5 01f9007fb116ac32c6b8b6d79d1dddbe)
set(JSON_FORTRAN_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
  -DSKIP_DOC_GEN=ON
  -DBUILD_SHARED_LIBS=OFF
  -DUSE_GNU_INSTALL_CONVENTION=ON
)
ExternalProject_Add(json_fortran_proj
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/json-fortran
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/downloads
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/json-fortran-src
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/json-fortran-bld
  URL ${JSON_FORTRAN_DOWNLOAD_URL}
  URL_MD5 ${JSON_FORTRAN_MD5}
  UPDATE_COMMAND ""
  CMAKE_ARGS ${JSON_FORTRAN_CMAKE_ARGS}
  LOG_CONFIGURE TRUE
  BUILD_COMMAND make
  LOG_BUILD TRUE
  INSTALL_COMMAND make install
  LOG_INSTALL TRUE
  LOG_OUTPUT_ON_FAILURE TRUE
)

# SuiteSparse for solving sparse linear systems (for CAMP)
# NOTE: we must build shared libraries for SuiteSparse because of
# NOTE: licensing terms (the LGPL, specifically)
set(SUITESPARSE_VERSION 7.8.2)
set(SUITESPARSE_DOWNLOAD_URL https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v${SUITESPARSE_VERSION}.zip)
set(SUITESPARSE_MD5 b02bbfa2c701bce10928bfa8b7683d75)
set(SUITESPARSE_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DBUILD_SHARED_LIBS=ON
)
# need to use CMAKE_CACHE_ARGS for lists
set(SUITESPARSE_CMAKE_CACHE_ARGS
  -DSUITESPARSE_ENABLE_PROJECTS:STRING=amd;btf;colamd;klu
)
ExternalProject_Add(suitesparse_proj
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/SuiteSparse
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/downloads
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/SuiteSparse-src
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/SuiteSparse-bld
  URL ${SUITESPARSE_DOWNLOAD_URL}
  URL_MD5 ${SUITESPARSE_MD5}
  UPDATE_COMMAND ""
  CMAKE_ARGS ${SUITESPARSE_CMAKE_ARGS}
  CMAKE_CACHE_ARGS ${SUITESPARSE_CMAKE_CACHE_ARGS}
  LOG_CONFIGURE TRUE
  BUILD_COMMAND make -j
  LOG_BUILD TRUE
  INSTALL_COMMAND make install
  LOG_INSTALL TRUE
  LOG_OUTPUT_ON_FAILURE TRUE
)
# copy klu.h and other headers into ${CMAKE_BINARY_DIR}/include,
# where CAMP expects them
set(SS_INC_DIR ${CMAKE_BINARY_DIR}/include/suitesparse)
ExternalProject_Add_Step(suitesparse_proj install_klu_h
  COMMENT "Copying SuiteSparse headers into ${CMAKE_BINARY_DIR}/include for CAMP..."
  COMMAND cmake -E chdir ${SS_INC_DIR} cmake -E copy amd.h colamd.h klu.h btf.h SuiteSparse_config.h ${CMAKE_BINARY_DIR}/include
  DEPENDEES install
)

# CAMP for gas-phase chemistry
# FIXME: we're temporarily using a feature branch that fixes some issues in CAMP
#set(CAMP_DOWNLOAD_URL https://github.com/AMBRS-Project/camp/archive/refs/heads/main.zip)
set(CAMP_DOWNLOAD_URL https://github.com/AMBRS-project/camp/archive/refs/heads/std-c-fixes.zip)
set(CAMP_MD5 279ba6a368ba27b3ed0aee8fdb5443e8)
set(CAMP_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_Fortran_COMPILER=${CMAKE_Fortran_COMPILER}
)
ExternalProject_Add(camp
  PREFIX ${CMAKE_CURRENT_BINARY_DIR}/camp
  DOWNLOAD_DIR ${CMAKE_CURRENT_SOURCE_DIR}/downloads
  SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/camp-src
  BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/camp-bld
  URL ${CAMP_DOWNLOAD_URL}
  URL_MD5 ${CAMP_MD5}
  DEPENDS json_fortran_proj
  UPDATE_COMMAND ""
  # we have to pass JSON_FORTRAN_HOME to cmake via cmake -E env below
  CONFIGURE_COMMAND cmake -E env JSON_FORTRAN_HOME=${CMAKE_BINARY_DIR} SUNDIALS_HOME=${CMAKE_BINARY_DIR} cmake -S ${CMAKE_CURRENT_BINARY_DIR}/camp-src -B ${CMAKE_CURRENT_BINARY_DIR}/camp-bld ${CAMP_CMAKE_ARGS}
  LOG_CONFIGURE TRUE
  BUILD_COMMAND make
  LOG_BUILD TRUE
  INSTALL_COMMAND make install
  LOG_INSTALL TRUE
  LOG_OUTPUT_ON_FAILURE TRUE
)
# build CAMP's patched/old version of CVODE for solving chemistry ODEs
set(CAMP_CVODE_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/camp-src/cvode-3.4-alpha)
set(CAMP_CVODE_BUILD_DIR ${CMAKE_CURRENT_BINARY_DIR}/camp-cvode-bld)
set(CAMP_CVODE_TARBALL ${CAMP_CVODE_SOURCE_DIR}.tar.gz)
set(CAMP_CVODE_CMAKE_ARGS
  -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DBUILD_SHARED_LIBS=ON
  -DKLU_ENABLE=ON
  -DKLU_LIBRARY_DIR=${CMAKE_BINARY_DIR}/lib
  -DKLU_INCLUDE_DIR=${CMAKE_BINARY_DIR}/include
)
ExternalProject_Add_Step(camp build-cvode
  COMMENT "Building CAMP-specific CVODE..."
  COMMAND cmake -E tar xfz ${CAMP_CVODE_TARBALL}
  COMMAND cmake -S ${CAMP_CVODE_SOURCE_DIR} -B ${CAMP_CVODE_BUILD_DIR} ${CAMP_CVODE_CMAKE_ARGS}
  COMMAND cmake -E chdir ${CAMP_CVODE_BUILD_DIR} make -j
  COMMAND cmake -E chdir ${CAMP_CVODE_BUILD_DIR} make install
  LOG TRUE
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/camp-src
  DEPENDEES patch     # CAMP must be downloaded before this step
  DEPENDERS configure # CAMP must be configured after this step
)
ExternalProject_Add_Step(camp relocate-camp-headers
  COMMENT "Copying CAMP headers to where PartMC can find them..."
  COMMAND cmake -E copy_directory ${CMAKE_BINARY_DIR}/include/camp ${CMAKE_BINARY_DIR}/include
  LOG TRUE
  DEPENDEES install # CAMP must be installed before this step
)
