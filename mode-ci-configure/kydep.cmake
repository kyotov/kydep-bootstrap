include(tools)
include(configure)

# AppendRequires -- adds a CI dependency for each item in ${ARGN} to ${YML}
# (provided in parent)
#
function(AppendRequires)
    set(DEPS "${ARGN}")
    list(TRANSFORM DEPS PREPEND "\n            - ")
    list(JOIN DEPS "" DEPS)
    string(APPEND YML "${DEPS}")
    SetInParent(YML)
endfunction()

# KyDep -- shim for KyDep macro when running in ci configuration context
#
macro(KyDep KYDEP)
    AddContext("KyDep::declare")
    Configure("${KYDEP}")
    DefineVars(${KYDEP} ${ARGN})

    cmake_parse_arguments("" "DEPENDS_DONE" "" "DEPENDS" ${ARGN})

    set(${KYDEP}_DEPENDENCY DEPENDS ${KYDEP} DEPENDS_DONE)

    list(APPEND KYDEPS "${KYDEP}")

    string(
        CONFIGURE
            "
      - build-package:
          # ${KYDEP}.${${KYDEP}_HASH}
          name: ${KYDEP}
          package-name: ${KYDEP}
          requires:
            - start"
            YML)
    AppendRequires(${_DEPENDS})
    list(APPEND KYDEPS_YML "${YML}")

    PopContext()
endmacro()

# KyDepRegister shim
macro(KyDepRegister)

endmacro()

# KyDeps shim
macro(KyDeps)
    set(YML
        "
version: 2.1

executors:
  kydeps-executor:
    docker:
      - image: kyotov/kydeps:latest
        auth:
          username: mydockerhub-user
          password: $DOCKERHUB_PASSWORD

# TODO(kamen): this does not belong to dynamic code...
commands:
  build-one:
    parameters:
      source-dir:
        default: ~/src
        type: string
      binary-dir:
        default: ~/build
        type: string
      extra-parameters:
        default: ''
        type: string
    steps:
      - run: cd <<parameters.source-dir>> && git submodule update --init --recursive
      - run: mkdir -p <<parameters.binary-dir>>
      - run: cd <<parameters.binary-dir>> && cmake -S <<parameters.source-dir>> -B . -D CMAKE_BUILD_TYPE=Debug <<parameters.extra-parameters>>
      - run: cd <<parameters.binary-dir>> && cmake --build . --config Debug
      - run: cd <<parameters.binary-dir>> && ./tests

jobs:

  # TODO(kamen): this does not belong to dynamic code...
  build-simple:
    executor: kydeps-executor
    parameters:
      source-dir:
        default: ~/src
        type: string
      binary-dir:
        default: ~/build
        type: string
      extra-parameters:
        default: ''
        type: string
    working_directory: ~/src
    steps:
      - checkout
      - build-one:
          source-dir: <<parameters.source-dir>>
          binary-dir: <<parameters.binary-dir>>
          extra-parameters: <<parameters.extra-parameters>>

  build-and-persist:
    executor: kydeps-executor
    working_directory: ~/src
    steps:
      - checkout
      - build-one:
          source-dir: ~/src/mode-3
          binary-dir: ~/build
          extra-parameters: -D KYDEPS_CACHE=ON
      - persist_to_workspace:
          root: ~/build/c
          paths: '*'
  
  build-by-reuse:
    executor: kydeps-executor
    working_directory: ~/src
    steps:
      - checkout
      - attach_workspace:
          at: /tmp/bucket
      - run: find /tmp/bucket
      - run: cp /tmp/bucket/cache.cmake ~/src/mode-1/kydeps/cache.cmake
      - build-one:
          source-dir: ~/src/mode-3
          extra-parameters: '--log-level DEBUG -D KYDEPS_CACHE=ON -D KYDEPS_BUILD=OFF -D KYDEPS_CACHE_BUCKET=file:///tmp/bucket -D KYDEPS_LOG_LEVEL=DEBUG'

  build-status:
    executor: kydeps-executor
    working_directory: ~/src
    steps:
      - attach_workspace:
          at: /tmp/cache
      - run: find /tmp/cache

  build-package:
    executor: kydeps-executor
    parameters:
      package-name:
        type: string
      source-dir:
        default: ~/src/mode-dist-build/kydeps
        type: string
      binary-dir:
        default: ~/build
        type: string
    working_directory: ~/src
    steps:
      - attach_workspace:
          at: /tmp/cache
      - run: find /tmp/cache
      - checkout
      - run: cd <<parameters.source-dir>> && git submodule update --init --recursive
      - run: mkdir -p <<parameters.binary-dir>>
      - run: |
          cd <<parameters.binary-dir>> &&
          cmake \\
            -S <<parameters.source-dir>> \\
            -B . \\
            -D CMAKE_BUILD_TYPE=Debug \\
            -D KYDEPS_TARGETS=<<parameters.package-name>> \\
            -D KYDEPS_CACHE_DIR=/tmp/cache \\
            -D KYDEPS_CI_UNIVERSE_BUILD=ON
      - run: cp <<parameters.binary-dir>>/c/cache.cmake <<parameters.binary-dir>>/c/<<parameters.package-name>>.cmake
      - run: find <<parameters.binary-dir>>/c
      - persist_to_workspace:
          root: <<parameters.binary-dir>>/c
          paths: <<parameters.package-name>>.*

workflows:
  simple:
    jobs:
      - build-simple:
          source-dir: ~/src/mode-1
      - build-simple:
          source-dir: ~/src/mode-2
      - build-simple:
          source-dir: ~/src/mode-3

  remote:
    jobs:
      - build-and-persist
      - build-by-reuse:
          requires: 
            - build-and-persist

  distributed-build:
    jobs:
      - hold:
          type: approval
      - build-status:
          name: start
          requires:
            - hold")

    foreach(KYDEP_YML ${KYDEPS_YML})
        string(APPEND YML "${KYDEP_YML}")
    endforeach()

    string(
        APPEND
        YML
        "
      - build-status:
          name: end
          requires:
            - start")
    AppendRequires(${KYDEPS})

    file(WRITE "${CMAKE_BINARY_DIR}/universe.yml" ${YML})
    message(
        STATUS
            "CI Universe Build Config generated at ${CMAKE_BINARY_DIR}/universe.yml"
    )
endmacro()
