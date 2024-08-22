# AMBuilder

AMBuilder is a CMake setup that builds the box models used by the AMBRS
Project in configurations of interest. Supported box models are:

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

These options can be passed to CMake using the `-D` flag

* `MOSAIC_SOURCE_DIR=</path/to/mosaic/source>`: enables MOSAIC in relevant
  box models, building it from the source in the given directory.
