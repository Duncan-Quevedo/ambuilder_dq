# We download CARMA and build a configurable box model version directly.

# download and extract the source
set(CARMA_SOURCE_URL https://github.com/AMBRS-project/CARMA_base/archive/refs/heads/main.zip)
set(CARMA_SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/CARMA_base-main)
if (NOT EXISTS ${CARMA_SOURCE_DIR})
  file(DOWNLOAD ${CARMA_SOURCE_URL} ${CMAKE_CURRENT_BINARY_DIR}/CARMA_base-main.zip)
  file(ARCHIVE_EXTRACT INPUT ${CMAKE_CURRENT_BINARY_DIR}/CARMA_base-main.zip)
endif()

# build the box model
add_executable(carma
  ${CARMA_SOURCE_DIR}/adgaquad_types_mod.F90
  ${CARMA_SOURCE_DIR}/adgaquad_mod.F90
  ${CARMA_SOURCE_DIR}/carma_constants_mod.F90
  ${CARMA_SOURCE_DIR}/carma_enums_mod.F90
  ${CARMA_SOURCE_DIR}/carma_mod.F90
  ${CARMA_SOURCE_DIR}/carma_precision_mod.F90
  ${CARMA_SOURCE_DIR}/carma_types_mod.F90
  ${CARMA_SOURCE_DIR}/carmaelement_mod.F90
  ${CARMA_SOURCE_DIR}/carmagas_mod.F90
  ${CARMA_SOURCE_DIR}/carmagroup_mod.F90
  ${CARMA_SOURCE_DIR}/carmasolute_mod.F90
  ${CARMA_SOURCE_DIR}/carmastate_mod.F90
  ${CARMA_SOURCE_DIR}/fixcorecol.F90
  ${CARMA_SOURCE_DIR}/fractal_meanfield_mod.F90
  ${CARMA_SOURCE_DIR}/lusolvec_mod.F90
  ${CARMA_SOURCE_DIR}/mie.F90

  atmosphere_mod.F90
  carma_testutils.F90
  carma.F90
)

# These macros are defined in ${MAM4_SOURCE_DIR}/test_drivers/cambox_config.cpp.in.
#target_compile_definitions(carma PRIVATE CAMBOX_ACTIVATE_THIS;CAMBOX_DEACTIVATE_THIS;MODAL_AERO;MODAL_AERO_4MODE_MOM;DRAIN_EVAP_TO_COARSE_AERO;PCNST=35;PCOLS=1;PVER=1;NBC=1;NPOA=1;NSOA=1)

install(TARGETS carma DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
