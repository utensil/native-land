// use futures::FutureExt;
// use std::{cell::RefCell, sync::Arc};

use dioxus::prelude::*;
use dx_xp::hello_div;

#[test]
fn test() {
    assert_rsx_eq(
        hello_div(),
        rsx! {
            for _ in 0..2 {
                div { "Hello world" }
            }
        },
    )
}

fn assert_rsx_eq(first: Element, second: Element) {
    let first = dioxus_ssr::render_element(first);
    let second = dioxus_ssr::render_element(second);
    pretty_assertions::assert_str_eq!(first, second);
}