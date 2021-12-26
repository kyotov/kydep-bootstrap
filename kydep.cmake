macro(KyDep NAME)

    include(ExternalProject)

    ExternalProject_Add(${NAME}
        PREFIX "${NAME}"
        
        BINARY_DIR "${NAME}/b"
        SOURCE_DIR "${NAME}/s"
        STAMP_DIR "${NAME}/ts"
        TMP_DIR "${NAME}/tmp"
        LOG_DIR "${NAME}/log"

        CMAKE_ARGS
        -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        -D CMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/${NAME}/i
        -D "CMAKE_MESSAGE_INDENT=${CMAKE_MESSAGE_INDENT}[${NAME}]"

        ${ARGN}
    )

    set(DEPENDS_ON_${NAME}
        CMAKE_ARGS
        -DCMAKE_PREFIX_PATH:PATH=${CMAKE_BINARY_DIR}/${NAME}/i
        DEPENDS ${NAME}
    )

endmacro()
