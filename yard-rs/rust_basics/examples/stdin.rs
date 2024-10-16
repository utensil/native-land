use std::io;

fn main() {
    let mut input = String::default();
    io::stdin().read_line(&mut input).unwrap_or_default();
    println!(
        "{}",
        input
            .split_whitespace()
            .filter_map(|x| x.parse::<i64>().ok())
            .fold(0, |acc, x| acc + x)
    );
}
