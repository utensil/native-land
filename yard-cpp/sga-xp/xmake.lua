add_rules("mode.debug") -- , "mode.release")
-- https://xmake.io/#/guide/project_examples?id=integrating-the-c-modules-package
set_languages("c++23")

target("sga-xp")
    set_kind("binary")
    add_includedirs("$(scriptdir)/../../yard-rs/rust_cpp/libs/ganim/src")
    add_files("src/*.cpp")
