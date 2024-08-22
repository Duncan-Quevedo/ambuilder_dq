find_path(NETCDF_INCLUDE_DIR netcdf.mod NETCDF.mod
  DOC "NetCDF include directory (must contain netcdf.mod)"
  PATHS
  $ENV{NETCDF_HOME}/include
  /usr/lib/gfortran/modules
  /usr/lib64/gfortran/modules
  /opt/local/include)
find_library(Z_LIB z
  DOC "libz"
  PATHS $ENV{NETCDF_HOME}/lib /opt/local/lib)
find_library(HDF5_LIB hdf5
  DOC "HDF5 library"
  PATHS $ENV{NETCDF_HOME}/lib /opt/local/lib)
find_library(HDF5_HL_LIB hdf5_hl
  DOC "HDF5 high-level library"
  PATHS $ENV{NETCDF_HOME}/lib /opt/local/lib)
find_library(NETCDF_C_LIB netcdf
  DOC "NetCDF C library"
  PATHS $ENV{NETCDF_HOME}/lib /opt/local/lib)
find_library(NETCDF_FORTRAN_LIB netcdff
  DOC "NetCDF Fortran library"
  PATHS $ENV{NETCDF_HOME}/lib /opt/local/lib)
set(NETCDF_LIBS ${NETCDF_C_LIB})
if(NETCDF_FORTRAN_LIB)
  set(NETCDF_LIBS ${NETCDF_FORTRAN_LIB} ${NETCDF_LIBS} ${HDF5_HL_LIB} ${HDF5_LIB} ${Z_LIB})
endif()
include_directories(${NETCDF_INCLUDE_DIR})
