c++ -O3 -Wall -shared -std=c++11 -fPIC \
  `~/Hunyuan3D-2.1/hunyuan/bin/python -m pybind11 --includes` \
  mesh_inpaint_processor.cpp \
  -o mesh_inpaint_processor`~/Hunyuan3D-2.1/hunyuan/bin/python -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))"`
