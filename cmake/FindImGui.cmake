if(ImGui_FOUND)
  return()
endif()

find_path(ImGui_INCLUDE_DIR
  NAMES imgui.h
  PATHS ${CMAKE_SOURCE_DIR}/vendor/imgui
  NO_DEFAULT_PATH
)
mark_as_advanced(ImGui_INCLUDE_DIR)

if(EXISTS "${ImGui_INCLUDE_DIR}/imgui.h")
  file(STRINGS "${ImGui_INCLUDE_DIR}/imgui.h" ImGui_H REGEX "^#define IMGUI_VERSION ")
  string(REGEX REPLACE "^.*\"([^\"]*)\".*$" "\\1" ImGui_VERSION "${ImGui_H}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ImGui
  REQUIRED_VARS ImGui_INCLUDE_DIR
  VERSION_VAR   ImGui_VERSION
)

add_library(imgui
  ${ImGui_INCLUDE_DIR}/imgui.cpp
  ${ImGui_INCLUDE_DIR}/imgui_draw.cpp
  ${ImGui_INCLUDE_DIR}/imgui_tables.cpp
  ${ImGui_INCLUDE_DIR}/imgui_widgets.cpp
  ${ImGui_INCLUDE_DIR}/misc/cpp/imgui_stdlib.cpp
)

target_compile_features(imgui PRIVATE cxx_std_17)
target_compile_definitions(imgui PUBLIC
  "IMGUI_USER_CONFIG=\"${CMAKE_CURRENT_SOURCE_DIR}/imconfig.h\"")
target_include_directories(imgui PUBLIC ${ImGui_INCLUDE_DIR})

add_library(ImGui::ImGui ALIAS imgui)
