include_guard(GLOBAL)

macro(set_in_parent name)
    set(${name}
        "${${name}}"
        PARENT_SCOPE)
endmacro()

function(check_set name)
    if("${${name}}" STREQUAL "")
        message(FATAL_ERROR "required `${name}` not set")
    endif()
endfunction()

function(compute_hash kydep)
    # construct the manifest string
    # TODO(kamen): figure out what else we need to put into it? * machine
    # details? * bootstrap version? * compiler / ABI?
    #
    set(manifest_list "MANIFEST[${kydep}]" "----------" ${ARGN} "----------")
    list(JOIN manifest_list "\n  " ${kydep}_MANIFEST)
    string(SHA1 ${kydep}_HASH "${${kydep}_MANIFEST}")

    set_in_parent(${kydep}_MANIFEST)
    set_in_parent(${kydep}_HASH)

    message(VERBOSE "${${kydep}_MANIFEST} -> ${${kydep}_HASH}")
endfunction()

macro(define_vars name)
    # message(WARNING "${CMAKE_SOURCE_DIR}")
    compute_hash(${name} ${ARGN})
    set(${name}_DEPENDENCY
        CMAKE_ARGS
        "-DCMAKE_PREFIX_PATH:PATH=${ROOT_BINARY_DIR}/i/${name}.${${name}_HASH}" #
        DEPENDS
        ${name})
endmacro()
