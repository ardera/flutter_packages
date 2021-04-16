@echo off
pushd ..\..\tools\bindings_generator
generate_bindings.bat
popd
copy ..\..\tools\bindings_generator\generated\*  .\lib\src\bindings\