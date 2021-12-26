cmake_minimum_required(VERSION 3.20)
project(kydep-bootstrap)

list(APPEND CMAKE_MESSAGE_INDENT "[KYDEPS]")

get_filename_component(DIR_NAME "${DEPS_SOURCE_DIR}" NAME)
set(DEPS_BINARY_DIR "${CMAKE_BINARY_DIR}/${DIR_NAME}")

if ("${DEPS_SOURCE_DIR}/CMakeLists.txt" IS_NEWER_THAN ${DEPS_BINARY_DIR}/done)

    message(STATUS "dependencies need rebuild...")

    execute_process(COMMAND ${CMAKE_COMMAND} 
        -S ${DEPS_SOURCE_DIR} 
        -B ${DEPS_BINARY_DIR} 
        -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -D CMAKE_MODULE_PATH=${CMAKE_CURRENT_SOURCE_DIR} # for kydep.cmake
        -D CMAKE_MESSAGE_INDENT=${CMAKE_MESSAGE_INDENT}
        -D "KYDEPS=${KYDEPS}"
    )

    execute_process(COMMAND ${CMAKE_COMMAND} --build ${DEPS_BINARY_DIR})

    message(STATUS "rebuild done.")
    file(TOUCH ${DEPS_BINARY_DIR}/done)

endif()

foreach(KYDEP ${KYDEPS})
    message(STATUS "adding `${DEPS_BINARY_DIR}/${KYDEP}/i` to prefix path")
    list(APPEND CMAKE_PREFIX_PATH ${DEPS_BINARY_DIR}/${KYDEP}/i)
endforeach()
set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)
