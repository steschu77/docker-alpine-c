# Dockerfile for steschu/alpine-c

This Docker image is intended to be used for CI builds of C/C++ based projects that use CMake for their project description.

The image also includes the GNU gold linker, ninja, cppcheck, an assembler and the OpenSSL library as well as wget and ccache.

Due to its intended use in CI, the image is kept as small as possible while still providing all meaningful tools for building C/C++ projects.

When using ccache for building your C/C++ project include the following steps in your CI:

- Use wget/tar/gzip to pull and extract the `.ccache` from a previous build (e.g. last successful master build).
- Setup ccache (cache location, cache size limit).
- Hook ccache into compiler tool-chain (e.g. `export PATH="/usr/lib/ccache/bin:$PATH"`).
- Use CMake to create the make file (e.g. `cmake -GNinja ..`).
- Build your project with ninja.
- Upload the cache to an artifact store.

See also the included [example.sh](example.sh) build script.

## Example CI integration in Gitlab.com

Example `.gitlab-ci.yml` for integration in GitLab.

```
image:
  steschu/alpine-c

build:
  stage: build
  script:
    - 'wget -O ccache.tar.gz --header "JOB-TOKEN: $CI_JOB_TOKEN" "https://gitlab.com/api/v4/projects/<user-id>%2F<project-id>/jobs/artifacts/master/raw/ccache.tar.gz?job=build_cache" || true'
    - scripts/build.sh
  except:
    - master

build_cache:
  stage: build
  script:
    - 'wget -O ccache.tar.gz --header "JOB-TOKEN: $CI_JOB_TOKEN" "https://gitlab.com/api/v4/projects/<user-id>%2F<project-id>/jobs/artifacts/master/raw/ccache.tar.gz?job=build_cache" || true'
    - scripts/build.sh
  only:
    - master
  artifacts:
    paths:
      - ccache.tar.gz
    expire_in: 1 week
```

## Example CMakeLists.txt for using GNU Gold Linker

Add the following to your CMakeLists.txt if you want to use the included Gold linker.

```
if (UNIX AND NOT APPLE)
  execute_process(COMMAND ${CMAKE_C_COMPILER} -fuse-ld=gold -Wl,--version ERROR_QUIET OUTPUT_VARIABLE ld_version)
  if ("${ld_version}" MATCHES "GNU gold")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=gold -Wl,--disable-new-dtags")
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fuse-ld=gold -Wl,--disable-new-dtags")
  endif()
endif()
```

This snippet has been stolen from [https://www.bitsnbites.eu/faster-c-builds/].
