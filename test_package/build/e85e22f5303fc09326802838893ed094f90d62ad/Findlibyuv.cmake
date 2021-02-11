

function(conan_message MESSAGE_OUTPUT)
    if(NOT CONAN_CMAKE_SILENT_OUTPUT)
        message(${ARGV${0}})
    endif()
endfunction()


macro(conan_find_apple_frameworks FRAMEWORKS_FOUND FRAMEWORKS FRAMEWORKS_DIRS)
    if(APPLE)
        foreach(_FRAMEWORK ${FRAMEWORKS})
            # https://cmake.org/pipermail/cmake-developers/2017-August/030199.html
            find_library(CONAN_FRAMEWORK_${_FRAMEWORK}_FOUND NAME ${_FRAMEWORK} PATHS ${FRAMEWORKS_DIRS} CMAKE_FIND_ROOT_PATH_BOTH)
            if(CONAN_FRAMEWORK_${_FRAMEWORK}_FOUND)
                list(APPEND ${FRAMEWORKS_FOUND} ${CONAN_FRAMEWORK_${_FRAMEWORK}_FOUND})
            else()
                message(FATAL_ERROR "Framework library ${_FRAMEWORK} not found in paths: ${FRAMEWORKS_DIRS}")
            endif()
        endforeach()
    endif()
endmacro()


function(conan_package_library_targets libraries package_libdir deps out_libraries out_libraries_target build_type package_name)
    unset(_CONAN_ACTUAL_TARGETS CACHE)
    unset(_CONAN_FOUND_SYSTEM_LIBS CACHE)
    foreach(_LIBRARY_NAME ${libraries})
        find_library(CONAN_FOUND_LIBRARY NAME ${_LIBRARY_NAME} PATHS ${package_libdir}
                     NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
        if(CONAN_FOUND_LIBRARY)
            conan_message(STATUS "Library ${_LIBRARY_NAME} found ${CONAN_FOUND_LIBRARY}")
            list(APPEND _out_libraries ${CONAN_FOUND_LIBRARY})
            if(NOT ${CMAKE_VERSION} VERSION_LESS "3.0")
                # Create a micro-target for each lib/a found
                set(_LIB_NAME CONAN_LIB::${package_name}_${_LIBRARY_NAME}${build_type})
                if(NOT TARGET ${_LIB_NAME})
                    # Create a micro-target for each lib/a found
                    add_library(${_LIB_NAME} UNKNOWN IMPORTED)
                    set_target_properties(${_LIB_NAME} PROPERTIES IMPORTED_LOCATION ${CONAN_FOUND_LIBRARY})
                    set(_CONAN_ACTUAL_TARGETS ${_CONAN_ACTUAL_TARGETS} ${_LIB_NAME})
                else()
                    conan_message(STATUS "Skipping already existing target: ${_LIB_NAME}")
                endif()
                list(APPEND _out_libraries_target ${_LIB_NAME})
            endif()
            conan_message(STATUS "Found: ${CONAN_FOUND_LIBRARY}")
        else()
            conan_message(STATUS "Library ${_LIBRARY_NAME} not found in package, might be system one")
            list(APPEND _out_libraries_target ${_LIBRARY_NAME})
            list(APPEND _out_libraries ${_LIBRARY_NAME})
            set(_CONAN_FOUND_SYSTEM_LIBS "${_CONAN_FOUND_SYSTEM_LIBS};${_LIBRARY_NAME}")
        endif()
        unset(CONAN_FOUND_LIBRARY CACHE)
    endforeach()

    if(NOT ${CMAKE_VERSION} VERSION_LESS "3.0")
        # Add all dependencies to all targets
        string(REPLACE " " ";" deps_list "${deps}")
        foreach(_CONAN_ACTUAL_TARGET ${_CONAN_ACTUAL_TARGETS})
            set_property(TARGET ${_CONAN_ACTUAL_TARGET} PROPERTY INTERFACE_LINK_LIBRARIES "${_CONAN_FOUND_SYSTEM_LIBS};${deps_list}")
        endforeach()
    endif()

    set(${out_libraries} ${_out_libraries} PARENT_SCOPE)
    set(${out_libraries_target} ${_out_libraries_target} PARENT_SCOPE)
endfunction()


include(FindPackageHandleStandardArgs)

conan_message(STATUS "Conan: Using autogenerated Findlibyuv.cmake")
# Global approach
set(libyuv_FOUND 1)
set(libyuv_VERSION "cci.20201106")

find_package_handle_standard_args(libyuv REQUIRED_VARS
                                  libyuv_VERSION VERSION_VAR libyuv_VERSION)
mark_as_advanced(libyuv_FOUND libyuv_VERSION)


set(libyuv_INCLUDE_DIRS "/home/vagrant/.conan/data/libyuv/cci.20201106/_/_/package/3c82cd18909a6bb7e939d1ef7b359acdc8dcb639/include")
set(libyuv_INCLUDE_DIR "/home/vagrant/.conan/data/libyuv/cci.20201106/_/_/package/3c82cd18909a6bb7e939d1ef7b359acdc8dcb639/include")
set(libyuv_INCLUDES "/home/vagrant/.conan/data/libyuv/cci.20201106/_/_/package/3c82cd18909a6bb7e939d1ef7b359acdc8dcb639/include")
set(libyuv_RES_DIRS )
set(libyuv_DEFINITIONS )
set(libyuv_LINKER_FLAGS_LIST
        "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,SHARED_LIBRARY>:>"
        "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,MODULE_LIBRARY>:>"
        "$<$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>:>"
)
set(libyuv_COMPILE_DEFINITIONS )
set(libyuv_COMPILE_OPTIONS_LIST "" "")
set(libyuv_COMPILE_OPTIONS_C "")
set(libyuv_COMPILE_OPTIONS_CXX "")
set(libyuv_LIBRARIES_TARGETS "") # Will be filled later, if CMake 3
set(libyuv_LIBRARIES "") # Will be filled later
set(libyuv_LIBS "") # Same as libyuv_LIBRARIES
set(libyuv_SYSTEM_LIBS )
set(libyuv_FRAMEWORK_DIRS )
set(libyuv_FRAMEWORKS )
set(libyuv_FRAMEWORKS_FOUND "") # Will be filled later
set(libyuv_BUILD_MODULES_PATHS )

conan_find_apple_frameworks(libyuv_FRAMEWORKS_FOUND "${libyuv_FRAMEWORKS}" "${libyuv_FRAMEWORK_DIRS}")

mark_as_advanced(libyuv_INCLUDE_DIRS
                 libyuv_INCLUDE_DIR
                 libyuv_INCLUDES
                 libyuv_DEFINITIONS
                 libyuv_LINKER_FLAGS_LIST
                 libyuv_COMPILE_DEFINITIONS
                 libyuv_COMPILE_OPTIONS_LIST
                 libyuv_LIBRARIES
                 libyuv_LIBS
                 libyuv_LIBRARIES_TARGETS)

# Find the real .lib/.a and add them to libyuv_LIBS and libyuv_LIBRARY_LIST
set(libyuv_LIBRARY_LIST yuv)
set(libyuv_LIB_DIRS "/home/vagrant/.conan/data/libyuv/cci.20201106/_/_/package/3c82cd18909a6bb7e939d1ef7b359acdc8dcb639/lib")

# Gather all the libraries that should be linked to the targets (do not touch existing variables):
set(_libyuv_DEPENDENCIES "${libyuv_FRAMEWORKS_FOUND} ${libyuv_SYSTEM_LIBS} ")

conan_package_library_targets("${libyuv_LIBRARY_LIST}"  # libraries
                              "${libyuv_LIB_DIRS}"      # package_libdir
                              "${_libyuv_DEPENDENCIES}"  # deps
                              libyuv_LIBRARIES            # out_libraries
                              libyuv_LIBRARIES_TARGETS    # out_libraries_targets
                              ""                          # build_type
                              "libyuv")                                      # package_name

set(libyuv_LIBS ${libyuv_LIBRARIES})

foreach(_FRAMEWORK ${libyuv_FRAMEWORKS_FOUND})
    list(APPEND libyuv_LIBRARIES_TARGETS ${_FRAMEWORK})
    list(APPEND libyuv_LIBRARIES ${_FRAMEWORK})
endforeach()

foreach(_SYSTEM_LIB ${libyuv_SYSTEM_LIBS})
    list(APPEND libyuv_LIBRARIES_TARGETS ${_SYSTEM_LIB})
    list(APPEND libyuv_LIBRARIES ${_SYSTEM_LIB})
endforeach()

# We need to add our requirements too
set(libyuv_LIBRARIES_TARGETS "${libyuv_LIBRARIES_TARGETS};")
set(libyuv_LIBRARIES "${libyuv_LIBRARIES};")

set(CMAKE_MODULE_PATH "/home/vagrant/.conan/data/libyuv/cci.20201106/_/_/package/3c82cd18909a6bb7e939d1ef7b359acdc8dcb639/" ${CMAKE_MODULE_PATH})
set(CMAKE_PREFIX_PATH "/home/vagrant/.conan/data/libyuv/cci.20201106/_/_/package/3c82cd18909a6bb7e939d1ef7b359acdc8dcb639/" ${CMAKE_PREFIX_PATH})

foreach(_BUILD_MODULE_PATH ${libyuv_BUILD_MODULES_PATHS})
    include(${_BUILD_MODULE_PATH})
endforeach()

if(NOT ${CMAKE_VERSION} VERSION_LESS "3.0")
    # Target approach
    if(NOT TARGET libyuv::libyuv)
        add_library(libyuv::libyuv INTERFACE IMPORTED)
        if(libyuv_INCLUDE_DIRS)
            set_target_properties(libyuv::libyuv PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
                                  "${libyuv_INCLUDE_DIRS}")
        endif()
        set_property(TARGET libyuv::libyuv PROPERTY INTERFACE_LINK_LIBRARIES
                     "${libyuv_LIBRARIES_TARGETS};${libyuv_LINKER_FLAGS_LIST}")
        set_property(TARGET libyuv::libyuv PROPERTY INTERFACE_COMPILE_DEFINITIONS
                     ${libyuv_COMPILE_DEFINITIONS})
        set_property(TARGET libyuv::libyuv PROPERTY INTERFACE_COMPILE_OPTIONS
                     "${libyuv_COMPILE_OPTIONS_LIST}")
        
    endif()
endif()
