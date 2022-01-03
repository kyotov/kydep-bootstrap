include_guard(GLOBAL)

# NOTE: this is included by CMakeLists.txt and tools.cmake is already included

function(cache_fetch kydep)
    set(i_dir "${ROOT_BINARY_DIR}/i/${kydep}.${${kydep}_HASH}")

    if(EXISTS "${i_dir}")
        message(VERBOSE "[cache_fetch:skip] ${i_dir} (already exists)")
    else()
        if(KYDEPS_CACHE_LOOKUP)
            check_set(KYDEPS_CACHE_DIR)
            set(archive "${KYDEPS_CACHE_DIR}/${kydep}.${${kydep}_HASH}.zip")
            if(EXISTS ${archive})
                message(VERBOSE "[cache_fetch:hit] ${archive}")
                file(ARCHIVE_EXTRACT INPUT "${archive}" DESTINATION
                     "${ROOT_BINARY_DIR}")
            else()
                message(VERBOSE "[cache_fetch:miss] ${archive}")
            endif()
        else()
            message(VERBOSE "[cache_fetch:skip] ${archive} (cache disabled)")
        endif()
    endif()
endfunction()

function(cache_update kydep)
    if(KYDEPS_CACHE_UPDATE)
        check_set(KYDEPS_CACHE_DIR)
        file(MAKE_DIRECTORY "${KYDEPS_CACHE_DIR}")

        set(archive "${KYDEPS_CACHE_DIR}/${kydep}.${${kydep}_HASH}.zip")
        if(EXISTS ${archive})
            message(VERBOSE "[cache:skipped] ${archive} (already in cache)")
        else()
            file(
                ARCHIVE_CREATE
                OUTPUT
                "${archive}"
                PATHS
                "${ROOT_BINARY_DIR}/i/${kydep}.${${kydep}_HASH}"
                FORMAT
                "zip")
            message(VERBOSE "[cache:updated] ${archive}")
        endif()
    endif()
endfunction()
