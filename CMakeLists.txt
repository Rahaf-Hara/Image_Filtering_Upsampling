cmake_minimum_required(VERSION 3.9)

project( Image_Filtering_Upsampling LANGUAGES C CXX CUDA )

## Pakages

find_package ( OpenCV REQUIRED )

include_directories( ${OpenCV_INCLUDE_DIRS} )

find_package(OpenMP)

ADD_LIBRARY(cudaLibs src/kernels.cu)

## Executables
set_source_files_properties(filters PROPERTIES LANGUAGE "CUDA")
add_executable( filters src/main.cu )
target_link_libraries( filters ${OpenCV_LIBS} cudaLibs)
set_target_properties( filters PROPERTIES CMAKE_CUDA_SEPARABLE_COMPILATION ON)

set_source_files_properties(pointcloud PROPERTIES LANGUAGE "CUDA")
add_executable( pointcloud src/points.cu )
target_link_libraries( pointcloud ${OpenCV_LIBS} cudaLibs)
set_target_properties( pointcloud PROPERTIES CMAKE_CUDA_SEPARABLE_COMPILATION ON)

set_source_files_properties(pointcloud PROPERTIES LANGUAGE "CUDA")
add_executable( upsampling_gui src/gui.cu )
target_link_libraries( upsampling_gui ${OpenCV_LIBS} cudaLibs)
set_target_properties( upsampling_gui PROPERTIES CMAKE_CUDA_SEPARABLE_COMPILATION ON)