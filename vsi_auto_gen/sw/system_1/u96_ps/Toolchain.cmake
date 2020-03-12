include(CMakeForceCompiler)

# this one is important
set(CMAKE_SYSTEM_NAME Linux)

# specify the cross compiler
CMAKE_FORCE_C_COMPILER(aarch64-linux-gnu-gcc GNU)
CMAKE_FORCE_CXX_COMPILER(aarch64-linux-gnu-g++ GNU)
