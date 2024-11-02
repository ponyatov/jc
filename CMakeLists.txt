cmake_minimum_required(VERSION 3.16)
include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(jc)
idf_build_set_property(COMPILE_OPTIONS "-Wno-write-strings" APPEND)
