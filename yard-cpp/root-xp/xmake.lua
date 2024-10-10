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
    set_homepage("https://root.cern/")
    set_description("ROOT is a unified software package for the storage, processing, and analysis of scientific data.")
    set_license("LGPL-2.1")

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

    if is_plat("windows") then
        if is_arch("x64") then
            set_urls("https://root.cern/download/root_$(version).win64.vc17.zip")
            add_versions("v6.32.06", "9cff19b57c32a6e8986f7c8934c33ab288aae11e001426d32781a0eac71f8ed3")
        end
    end

    on_install("macosx", "linux", "windows", function (package)
        os.cp("*", package:installdir())
        -- below not working
        -- os.mv("include", package:installdir("include"))
        -- os.mv("lib", package:installdir("lib"))
    end)

    -- test with `xmake require -v --check root`
--     on_check(function (package)
--         assert(package:check_cxxsnippets({test = [[
-- #include <iostream>
-- #include <vector>

-- using std::vector;

-- int main() {
--     // Generate a vector with 10 random numbers.
--     vector<double> v(10);
--     std::generate(v.begin(), v.end(), rand);

--     // Find the minimum value of the vector (iterator version).
--     vector<double>::iterator it;
--     it = TMath::LocMin(v.begin(), v.end());
--     std::cout << *it << std::endl;

--     // The same with the old-style version.
--     int i;
--     i = TMath::LocMin(10, &v[0]);
--     std::cout << v[i] << std::endl;

--     return 0;
-- }
--         ]]}, {includes = {"TMath.h"}, configs = {languages = "c++20"}}))
--     end)

package_end()

-- configure: error: gmp library too old
-- error: execv(./configure --enable-shared=yes --enable-static=no --with-pic --with-gmp-prefix=~/.xmake/packages/g/gmp/6.3.0/24f1b85cb6534fe7b7485121640f8f39 --prefix=~/.xmake/packages/l/libisl/0.22/09ec4ac2cc9e454ba813de282118dd79) failed(1)
--   => install libisl 0.22 .. failed
-- error: install failed!
-- error: Recipe `run` failed on line 2 with exit code 255
-- add_requires("muslcc")
-- set_toolchains("@muslcc")

add_requires("root", {system = false})

-- add_requires("conda::root", {alias = "root"})

target("xmake-xp")
    set_kind("binary")
    add_files("src/*.cpp")
    add_packages("root")
    -- https://hatchjs.com/fatal-error-lnk1169-one-or-more-multiply-defined-symbols-found/
    add_ldflags("/ignore:4075") -- , {force = true})

-- xmake -y -v && xmake run
-- checking for the c++ compiler (cxx) ... cl.exe
-- checking for flags (-std:c++20) ... ok
-- [ 50%]: compiling.release src\main.cpp
-- "C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.41.34120\\bin\\HostX64\\x64\\cl.exe" -c -nologo -std:c++20 -DBOOST_ALL_NO_LIB /EHsc -external:W0 -external:IC:\Users\runneradmin\AppData\Local\.xmake\packages\s\stb\2024.06.01\50b5205a30f145adb70e146a5d0967dc\include -external:W0 -external:IC:\Users\runneradmin\AppData\Local\.xmake\packages\s\stb\2024.06.01\50b5205a30f145adb70e146a5d0967dc\include\stb -external:W0 -external:IC:\Users\runneradmin\AppData\Local\.xmake\packages\b\boost\1.86.0\26f0ead6f35b407c8240c616102f171b\include -external:W0 -external:IC:\Users\runneradmin\AppData\Local\.xmake\packages\s\sokol\2024.07.10\3ea7d73abd224fd49e7b250be801ffbb\include -external:W0 -external:IC:\Users\runneradmin\AppData\Local\.xmake\packages\r\raylib\5.0\55e75b1a4a50443e8f6e76ba932abc2b\include -external:W0 -external:IC:\Users\runneradmin\AppData\Local\.xmake\packages\r\root\v6.32.06\b7b85affe11d48a8a4f95efa95ddf42e\include -Fobuild\.objs\xmake-xp\windows\x64\release\src\main.cpp.obj src\main.cpp
-- checking for flags (cl_sourceDependencies) ... ok
-- checking for C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Tools\MSVC\14.41.34120\bin\HostX64\x64\link.exe ... ok
-- checking for flags (/ignore:4075) ... ok
-- [ 75%]: linking.release xmake-xp.exe
-- "C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\\VC\\Tools\\MSVC\\14.41.34120\\bin\\HostX64\\x64\\link.exe" -nologo -dynamicbase -nxcompat -machine:x64 -libpath:C:\Users\runneradmin\AppData\Local\.xmake\packages\b\boost\1.86.0\26f0ead6f35b407c8240c616102f171b\lib -libpath:C:\Users\runneradmin\AppData\Local\.xmake\packages\r\raylib\5.0\55e75b1a4a50443e8f6e76ba932abc2b\lib -libpath:C:\Users\runneradmin\AppData\Local\.xmake\packages\r\root\v6.32.06\b7b85affe11d48a8a4f95efa95ddf42e\lib libboost_atomic-mt-s.lib libboost_filesystem-mt-s.lib raylib.lib opengl32.lib libASImage.lib libASImageGui.lib libCling.lib libcomplexDict.lib libCore.lib libcppyy.lib libcppyy_backend.lib libdequeDict.lib libEG.lib libEve.lib libFitPanel.lib libFITSIO.lib libFoam.lib libforward_listDict.lib libFTGL.lib libFumili.lib libGdml.lib libGed.lib libGenetic.lib libGenVector.lib libGeom.lib libGeomBuilder.lib libGeomPainter.lib libGLEW.lib libGpad.lib libGraf.lib libGraf3d.lib libGui.lib libGuiBld.lib libGuiHtml.lib libGviz3d.lib libHist.lib libHistFactory.lib libHistPainter.lib libHtml.lib libImt.lib liblistDict.lib libmap2Dict.lib libmapDict.lib libMathCore.lib libMathMore.lib libMatrix.lib libMinuit.lib libMinuit2.lib libMLP.lib libmultimap2Dict.lib libmultimapDict.lib libmultisetDict.lib libNet.lib libPhysics.lib libPostscript.lib libPyMVA.lib libQuadp.lib libRCsg.lib libRecorder.lib libRGL.lib libRHTTP.lib libRHTTPSniff.lib libRint.lib libRIO.lib libRODBC.lib libRooBatchCompute.lib libRooBatchCompute_GENERIC.lib libRooFit.lib libRooFitCore.lib libRooFitHS3.lib libRooFitJSONInterface.lib libRooFitMore.lib libRooFitRDataFrameHelpers.lib libRooStats.lib libRootAuth.lib libROOTBranchBrowseProvider.lib libROOTBrowsable.lib libROOTBrowserGeomWidget.lib libROOTBrowserRCanvasWidget.lib libROOTBrowserTCanvasWidget.lib libROOTBrowserTreeWidget.lib libROOTBrowserv7.lib libROOTBrowserWidgets.lib libROOTCanvasPainter.lib libROOTDataFrame.lib libROOTEve.lib libROOTFitPanelv7.lib libROOTGeoBrowseProvider.lib libROOTGeomViewer.lib libROOTGpadv7.lib libROOTGraphicsPrimitives.lib libROOTHist.lib libROOTHistDraw.lib libROOTHistDrawProvider.lib libROOTLeafDraw6Provider.lib libROOTLeafDraw7Provider.lib libROOTNTuple.lib libROOTNTupleBrowseProvider.lib libROOTNTupleDraw6Provider.lib libROOTNTupleDraw7Provider.lib libROOTNTupleUtil.lib libROOTObjectDraw6Provider.lib libROOTObjectDraw7Provider.lib libROOTTMVASofie.lib libROOTTPython.lib libROOTTreeViewer.lib libROOTVecOps.lib libROOTWebDisplay.lib libsetDict.lib libSmatrix.lib libSpectrum.lib libSpectrumPainter.lib libSPlot.lib libSQLIO.lib libThread.lib libTMVA.lib libTMVAGui.lib libTMVAUtils.lib libTree.lib libTreePlayer.lib libTreeViewer.lib libunordered_mapDict.lib libunordered_multimapDict.lib libunordered_multisetDict.lib libunordered_setDict.lib libUnuran.lib libvectorDict.lib libWebGui6.lib libWin32gdk.lib libXMLIO.lib tbb.lib tbb12.lib gdi32.lib user32.lib winmm.lib shell32.lib /ignore:4075 -out:build\windows\x64\release\xmake-xp.exe build\.objs\xmake-xp\windows\x64\release\src\main.cpp.obj
-- error: libcpmt.lib(locale0.obj) : error LNK2005: "void __cdecl std::_Facet_Register(class std::_Facet_base *)" (?_Facet_Register@std@@YAXPEAV_Facet_base@1@@Z) already defined in libCling.lib(libCling.dll)
-- build\windows\x64\release\xmake-xp.exe : fatal error LNK1169: one or more multiply defined symbols found

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

