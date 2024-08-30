# AMBuilder

AMBuilder is a CMake setup that builds the box models used by the AMBRS
Project in configurations of interest. Supported box models are:

* CARMA
* MAM4
* PartMC

## Calling CMake Directly

To use CMake to build the box models and install them to a given folder
(shown here as `<prefix>`, with a `bin` subfolder), use the following commands:

```
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=<prefix> [options]
cd build
make
make install
```

### Configuration options

Additional options can be passed to CMake using the `-D` flag:

* `CMAKE_BUILD_TYPE={Debug,Release}`: builds debuggable or optimized versions
  of libraries and aerosol models (respectively)
