cmake_minimum_required(VERSION 3.20)
project(kydep_bootstrap)

macro(KyDep NAME)
    list(APPEND KYDEPS "${NAME}")
endmacro()

macro(KyDeps)

    get_filename_component(DIR_NAME "${kydeps_SOURCE_DIR}" NAME)
    set(kydeps_BINARY_DIR "${CMAKE_BINARY_DIR}/${DIR_NAME}")

    if ("${kydeps_SOURCE_DIR}/CMakeLists.txt" IS_NEWER_THAN ${kydeps_BINARY_DIR}/done)

        execute_process(COMMAND ${CMAKE_COMMAND} 
            -S ${kydeps_SOURCE_DIR} 
            -B ${kydeps_BINARY_DIR} 
            -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -D CMAKE_MODULE_PATH=${kydep_bootstrap_SOURCE_DIR} # for kydep.cmake
            -D CMAKE_MESSAGE_INDENT=${CMAKE_MESSAGE_INDENT}
            -D "KYDEPS=${KYDEPS}"
        )
        execute_process(COMMAND ${CMAKE_COMMAND} --build ${kydeps_BINARY_DIR})

        file(TOUCH ${kydeps_BINARY_DIR}/done)

    endif()

    foreach(KYDEP ${KYDEPS})
        set(DIR "${kydeps_BINARY_DIR}/${KYDEP}/i")
        message(STATUS "CMAKE_PREFIX_PATH += ${DIR}")        
        list(APPEND CMAKE_PREFIX_PATH "${DIR}")
    endforeach()

    set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" PARENT_SCOPE)

endmacro()

cmake_language(DEFER 
    DIRECTORY ${kydeps_SOURCE_DIR} 
    CALL KyDeps
)
