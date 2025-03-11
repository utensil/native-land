add_rules("mode.debug") -- , "mode.release")
-- https://xmake.io/#/guide/project_examples?id=integrating-the-c-modules-package
set_languages("c++20")

-- configure: error: gmp library too old
-- error: execv(./configure --enable-shared=yes --enable-static=no --with-pic --with-gmp-prefix=~/.xmake/packages/g/gmp/6.3.0/24f1b85cb6534fe7b7485121640f8f39 --prefix=~/.xmake/packages/l/libisl/0.22/09ec4ac2cc9e454ba813de282118dd79) failed(1)
--   => install libisl 0.22 .. failed
-- error: install failed!
-- error: Recipe `run` failed on line 2 with exit code 255
-- add_requires("muslcc")
-- set_toolchains("@muslcc")

-- add_requires("stb")
add_requires("boost", { configs = { all = true } })
add_requires("sokol")
add_requires("raylib")

target("xmake-xp")
set_kind("binary")
add_files("src/*.cpp")
-- add_packages("stb")
add_packages("boost")
add_packages("sokol")
add_packages("raylib")

--
-- If you want to known more usage about xmake, please see https://xmake.io
--
-- ## FAQ
--
-- You can enter the project directory firstly before building project.
--
--   $ cd projectdir
--
-- 1. How to build project?
--
--   $ xmake
--
-- 2. How to configure project?
--
--   $ xmake f -p [macosx|linux|iphoneos ..] -a [x86_64|i386|arm64 ..] -m [debug|release]
--
-- 3. Where is the build output directory?
--
--   The default output directory is `./build` and you can configure the output directory.
--
--   $ xmake f -o outputdir
--   $ xmake
--
-- 4. How to run and debug target after building project?
--
--   $ xmake run [targetname]
--   $ xmake run -d [targetname]
--
-- 5. How to install target to the system directory or other output directory?
--
--   $ xmake install
--   $ xmake install -o installdir
--
-- 6. Add some frequently-used compilation flags in xmake.lua
--
-- @code
--    -- add debug and release modes
--    add_rules("mode.debug", "mode.release")
--
--    -- add macro definition
--    add_defines("NDEBUG", "_GNU_SOURCE=1")
--
--    -- set warning all as error
--    set_warnings("all", "error")
--
--    -- set language: c99, c++11
--    set_languages("c99", "c++11")
--
--    -- set optimization: none, faster, fastest, smallest
--    set_optimize("fastest")
--
--    -- add include search directories
--    add_includedirs("/usr/include", "/usr/local/include")
--
--    -- add link libraries and search directories
--    add_links("tbox")
--    add_linkdirs("/usr/local/lib", "/usr/lib")
--
--    -- add system link libraries
--    add_syslinks("z", "pthread")
--
--    -- add compilation and link flags
--    add_cxflags("-stdnolib", "-fno-strict-aliasing")
--    add_ldflags("-L/usr/local/lib", "-lpthread", {force = true})
--
-- @endcode
--
