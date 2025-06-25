#[test]
fn test_compute_logic() {
    // Test the logic without Bevy runtime
    let input = vec![1., 2., 3., 4.];
    let value = 3.;

    // First pass: add value to each element
    let first_pass: Vec<f32> = input.iter().map(|x| x + value).collect();
    assert_eq!(first_pass, vec![4., 5., 6., 7.]);

    // Second pass: square each element
    let second_pass: Vec<f32> = first_pass.iter().map(|x| x * x).collect();
    assert_eq!(second_pass, vec![16., 25., 36., 49.]);
}
