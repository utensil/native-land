use dioxus::prelude::*;

pub fn hello_div() -> Element {
    rsx! {
        div { "Hello world" }
        div { "Hello world" }
    }
}