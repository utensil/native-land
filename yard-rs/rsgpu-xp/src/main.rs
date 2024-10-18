use rsgpu_xp::compute;

pub fn main() {
    let result = compute::start();

    for (src, out) in result.iter() {
        if *out == u32::MAX {
            println!("{src}: overflowed");
            break;
        } else {
            // Should produce <https://oeis.org/A006877>
            println!("{src}: {out}");
        }
    }
}
