cmake_minimum_required(VERSION 3.20)
project(
    kydep_bootstrap
    VERSION 2.1
    HOMEPAGE_URL https://github.com/kyotov/kydep-bootstrap)

include("${kydep_bootstrap_SOURCE_DIR}/tools.cmake")
include("${kydep_bootstrap_SOURCE_DIR}/cache.cmake")

set(ROOT_BINARY_DIR "${CMAKE_BINARY_DIR}")
set_in_parent(ROOT_BINARY_DIR)

# accumulates all dependency names added by KyDep in a list
#
macro(KyDep name)
    define_vars(${name} ${ARGN})
    cache_fetch(${name})
    list(APPEND KYDEPS "${name}")
endmacro()

# builds dependencies (if necessary) updates ${CMAKE_PREFIX_PATH} with their
# locations
#
macro(KyDeps)
    if("${kydeps_SOURCE_DIR}/CMakeLists.txt" IS_NEWER_THAN
       ${kydeps_BINARY_DIR}/done)

        execute_process(
            COMMAND
                ${CMAKE_COMMAND} #
                -S ${kydeps_SOURCE_DIR} #
                -B ${kydeps_BINARY_DIR} #
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} #
                -DCMAKE_MODULE_PATH=${kydep_bootstrap_SOURCE_DIR} #
                "-DCMAKE_MESSAGE_INDENT=${CMAKE_MESSAGE_INDENT}[BUILD]" #
                "-DROOT_BINARY_DIR=${ROOT_BINARY_DIR}"
                "-DKYDEPS=${KYDEPS}")

        execute_process(COMMAND ${CMAKE_COMMAND} --build ${kydeps_BINARY_DIR})

        file(TOUCH ${kydeps_BINARY_DIR}/done)
    endif()

    file(MAKE_DIRECTORY "${ROOT_BINARY_DIR}/i")
    foreach(kydep ${KYDEPS})
        set(i_dir "${ROOT_BINARY_DIR}/i/${kydep}.${${kydep}_HASH}")
        message(STATUS "CMAKE_PREFIX_PATH += ${i_dir}")
        list(APPEND CMAKE_PREFIX_PATH "${i_dir}")
        cache_update(${kydep})
    endforeach()

    set_in_parent(CMAKE_PREFIX_PATH)
    set_in_parent(KYDEPS)
endmacro()

cmake_language(DEFER DIRECTORY ${kydeps_SOURCE_DIR} CALL KyDeps)
