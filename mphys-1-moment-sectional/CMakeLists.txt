# We download Jeff Pierce's aerosol model and assemble a standalone driver
# script that can be run in a separate process to accommodate its (LGPL) license.

# download and extract the source
set(MPHYS_SOURCE_URL https://github.com/AMBRS-project/mphys-1-moment-sectional/archive/refs/heads/main.zip)
set(MPHYS_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/mphys-1-moment-sectional)
if (NOT EXISTS ${MPHYS_SOURCE_DIR})
  file(DOWNLOAD ${MPHYS_SOURCE_URL} ${CMAKE_SOURCE_DIR}/downloads/mphys-1-moment-sectional.zip)
  file(ARCHIVE_EXTRACT
    INPUT ${CMAKE_SOURCE_DIR}/downloads/mphys-1-moment-sectional.zip
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}
  )
endif()

# mash everything into a self-contained driver script
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/mphys-driver "#!/usr/bin/env python\n")
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/driver.py driver_py)
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/mphys-driver ${driver_py})
foreach(module
        dNdt_coag.py
        dNdt_cond.py
        dNdt_all.py
        get_coag_kernel.py)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/mphys-driver "\n# ${module}\n")
  file(READ ${MPHYS_SOURCE_DIR}/${module} module_src)
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/mphys-driver "${module_src}")
endforeach()

install(
  FILES ${CMAKE_CURRENT_BINARY_DIR}/mphys-driver
  DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
)
