add_rules("mode.debug") -- , "mode.release")
-- https://xmake.io/#/guide/project_examples?id=integrating-the-c-modules-package
set_languages("c++20")

-- https://root.cern/install/#build-from-source
-- https://xmake.io/#/package/remote_package?id=using-self-built-private-package-repository

-- package("root")
--     -- set_urls("https://github.com/root-project/root.git")
--     set_urls("https://github.com/root-project/root/archive/refs/tags/$(version).tar.gz")

--     add_versions("v6-32-06", "01a98aa656c33898690f0d7b1bc667ebdd7a5f74b34c237b59ea49eca367c9ea")

--     on_install("macosx", "linux", function (package)
--         local configs = {}
--         table.insert(configs, "-Dbuiltin_glew=ON")
--         import("package.tools.cmake").install(package, configs)
--     end)
-- package_end()
--
-- add_requires("root")

-- https://xmake.io/#/package/system_package?id=find-using-system-packages
-- download and install from https://root.cern/install/#download-a-pre-compiled-binary-distribution
-- hhttps://root.cern/download/root_v6.32.06.macos-15.0-arm64-clang160.tar.gz
-- add_requires("root", {system = true})

-- following https://gitlab.com/tboox/xmake-repo/-/blob/master/packages/v/vcpkg/xmake.lua
-- and https://gitlab.com/tboox/xmake-repo/-/blob/master/packages/o/onnxruntime/xmake.lua?ref_type=heads
package("root")
    if is_plat("macosx") then
        if is_arch("arm64") then
            set_urls("https://root.cern/download/root_$(version).macos-15.0-arm64-clang160.tar.gz")
            add_versions("v6.32.06", "a9676809678b93ab96e198bb0654f32e2d74c6dd0a7536537a7bfee674f262bd")
        end
    end

    if is_plat("linux") then
        if is_arch("x86_64") then
            set_urls("https://root.cern/download/root_$(version).Linux-ubuntu24.04-x86_64-gcc13.2.tar.gz")
            add_versions("v6.32.06", "57dabc4f35f21141eadd0a9add59a7a381b63d22430fe7467077c8bd0f732383")
        end
    end

    if is_plat("windows", "mingw") then
        if is_arch("x86_64") then
            set_urls("https://root.cern/download/root_$(version).win64.vc17.zip")
            add_versions("v6.32.06", "9cff19b57c32a6e8986f7c8934c33ab288aae11e001426d32781a0eac71f8ed3")
        end
    end

    on_install("macosx", "linux", "windows", "mingw", function (package)
        os.cp("*", package:installdir())
    end)

package_end()

-- configure: error: gmp library too old
-- error: execv(./configure --enable-shared=yes --enable-static=no --with-pic --with-gmp-prefix=~/.xmake/packages/g/gmp/6.3.0/24f1b85cb6534fe7b7485121640f8f39 --prefix=~/.xmake/packages/l/libisl/0.22/09ec4ac2cc9e454ba813de282118dd79) failed(1)
--   => install libisl 0.22 .. failed
-- error: install failed!
-- error: Recipe `run` failed on line 2 with exit code 255
-- add_requires("muslcc")
-- set_toolchains("@muslcc")

add_requires("root")

add_requires("stb")
add_requires("boost")
add_requires("sokol")
add_requires("raylib")
-- add_requires("conda::root", {alias = "root"})

target("xmake-xp")
    set_kind("binary")
    add_files("src/*.cpp")
    add_packages("stb")
    add_packages("boost")
    add_packages("sokol")
    add_packages("raylib")
    add_packages("root")

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

