include_guard(GLOBAL)

macro(KyDeps DEPS)
    set(DEPS_BINARY_DIR "${CMAKE_BINARY_DIR}/deps")

    # add basic check to only run this if the deps has changed...
    execute_process(COMMAND ${CMAKE_COMMAND} -S ${CMAKE_SOURCE_DIR}/deps -B ${DEPS_BINARY_DIR} -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
    execute_process(COMMAND ${CMAKE_COMMAND} --build ${DEPS_BINARY_DIR} --config ${CMAKE_BUILD_TYPE})

    foreach(DEP ${DEPS})
        list(APPEND CMAKE_PREFIX_PATH ${DEPS_BINARY_DIR}/${DEP}/i)
    endforeach()
endmacro()
