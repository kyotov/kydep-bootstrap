include(ExternalProject)
include(tools)

# a thin wrapper around ExternalProject_Add with some good defaults
macro(KyDep name)

    define_vars(${name} ${ARGN})

    set(i_dir "${ROOT_BINARY_DIR}/i/${name}.${${name}_HASH}")

    if(EXISTS "${i_dir}")
        message(STATUS "[KYDEP] ${i_dir} already installed, skipping build...")
        add_custom_target(${name})
    else()
        set(dir "${kydeps_BINARY_DIR}/${name}.${${name}_HASH}")
        ExternalProject_Add(
            ${name}
            PREFIX "${dir}"
            BINARY_DIR "${dir}/b"
            SOURCE_DIR "${dir}/s"
            STAMP_DIR "${dir}/ts"
            TMP_DIR "${dir}/tmp"
            LOG_DIR "${dir}/log"
            CMAKE_ARGS
                "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}" #
                "-DCMAKE_INSTALL_PREFIX:PATH=${i_dir}" #
                "-DCMAKE_MESSAGE_INDENT=${CMAKE_MESSAGE_INDENT}[${name}]" #
                "-DCMAKE_INSTALL_MESSAGE=NEVER" #
                ${ARGN})
    endif()

endmacro()
