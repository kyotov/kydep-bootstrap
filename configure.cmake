include_guard(GLOBAL)

# Configure -- set configuration variables important for KyDeps
#
macro(Configure)
    AddContext("Configure")
    get_property(
        SET_IF_EMPTY_SILENT GLOBAL
        PROPERTY CONFIGURE_SILENCER
        SET)

    SetIfEmpty(CMAKE_BUILD_TYPE Debug)

    SetIfEmpty(KYDEPS_BUILD ON)
    SetIfEmpty(KYDEPS_CACHE ON)

    SetIfEmpty(KYDEPS_BUILD_TESTS OFF)

    SetIfEmpty(KYDEPS_LOG_LEVEL Debug)

    SetIfEmpty(KYDEPS_TARGETS all)

    # TODO(kamen): document the below carefully
    SetIfEmpty(KYDEPS_BUILD_ONE_ENABLED OFF)
    if(KYDEP_BUILD_ONE_ENABLED)
        KyAssertSet(KYDEP_BUILD_ONE_TARGET)
        set(KYDEP_CACHE ON)
        if(KYDEP STREQUAL KYDEP_BUILD_ONE_TARGET)
            set(KYDEP_BUILD ON)
        else()
            set(KYDEP_BUILD OFF)
        endif()
    endif()

    set_property(GLOBAL PROPERTY CONFIGURE_SILENCER ON)
    PopContext()
endmacro()
