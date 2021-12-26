include_guard(GLOBAL)

include(ExternalProject)

function(KyDep NAME)
    message(STATUS "[KYDEP] ${NAME}")

    set(DIR "${CMAKE_BINARY_DIR}/${NAME}")

    ExternalProject_Add(${NAME}
        PREFIX "${DIR}"
        
        BINARY_DIR "${DIR}/b"
        SOURCE_DIR "${DIR}/s"
        STAMP_DIR "${DIR}/ts"
        TMP_DIR "${DIR}/tmp"
        LOG_DIR "${DIR}/log"

        CMAKE_ARGS
        -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -D CMAKE_INSTALL_PREFIX:PATH=${DIR}/i
        -D "CMAKE_MESSAGE_INDENT=${CMAKE_MESSAGE_INDENT}[${NAME}]"

        ${ARGN}
    )

    set(DEPENDS_ON_${NAME}
        CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${DIR}/i
        DEPENDS ${NAME}
        PARENT_SCOPE
    )
endfunction()
