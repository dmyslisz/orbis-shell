cmake_minimum_required(VERSION 3.20)
project(orbis-shell VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Qt 6 Core & GUI modules
find_package(Qt6 6.4 REQUIRED COMPONENTS Core Gui Quick Qml Multimedia)

# Optional SDL3 Gamepad support
find_package(PkgConfig QUIET)
find_package(SDL3 CONFIG QUIET)

if(TARGET SDL3::SDL3)
    message(STATUS "Found SDL3 via CMake target: SDL3::SDL3")
    set(HAVE_SDL3 TRUE)
    set(SDL3_TARGET SDL3::SDL3)
elseif(PkgConfig_FOUND)
    pkg_check_modules(SDL3 QUIET sdl3)
    if(SDL3_FOUND)
        message(STATUS "Found SDL3 via pkg-config (${SDL3_VERSION})")
        set(HAVE_SDL3 TRUE)
    endif()
endif()

if(NOT HAVE_SDL3)
    message(WARNING "SDL3 not found. Compiling with Qt gamepad/keyboard fallback.")
endif()

# Qt automoc / autorcc
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(SOURCES
    src/main.cpp
    src/config_manager.h
    src/config_manager.cpp
    src/gamepad_manager.h
    src/gamepad_manager.cpp
    src/process_launcher.h
    src/process_launcher.cpp
    src/sound_controller.h
    src/sound_controller.cpp
    src/app_scanner.h
    src/app_scanner.cpp
    src/steam_scanner.h
    src/steam_scanner.cpp
    src/system_manager.h
    src/system_manager.cpp
    resources.qrc
)

add_executable(orbis-shell ${SOURCES})

target_include_directories(orbis-shell PRIVATE
    src
    ${CMAKE_CURRENT_BINARY_DIR}
)

target_link_libraries(orbis-shell PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
    Qt6::Multimedia
)

if(HAVE_SDL3)
    target_compile_definitions(orbis-shell PRIVATE HAVE_SDL3=1)
    if(TARGET SDL3::SDL3)
        target_link_libraries(orbis-shell PRIVATE SDL3::SDL3)
    else()
        target_include_directories(orbis-shell PRIVATE ${SDL3_INCLUDE_DIRS})
        target_link_libraries(orbis-shell PRIVATE ${SDL3_LIBRARIES})
    endif()
endif()

# Copy config and asset directories to build dir for runtime editing/tunables
add_custom_command(TARGET orbis-shell POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_CURRENT_SOURCE_DIR}/config
        $<TARGET_FILE_DIR:orbis-shell>/config
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_CURRENT_SOURCE_DIR}/assets
        $<TARGET_FILE_DIR:orbis-shell>/assets
    COMMENT "Copying config and assets to build output directory"
)

# Install rules for Fedora Linux / Desktop Session
install(TARGETS orbis-shell RUNTIME DESTINATION bin)
install(DIRECTORY config DESTINATION share/orbis-shell)
install(DIRECTORY assets DESTINATION share/orbis-shell)

# Session files
install(PROGRAMS session/orbis-session DESTINATION bin)
install(FILES session/orbis-shell-wayland.desktop DESTINATION share/wayland-sessions)
install(FILES session/orbis-shell-x11.desktop DESTINATION share/xsessions)
install(FILES session/orbis-shell.desktop DESTINATION share/applications)
