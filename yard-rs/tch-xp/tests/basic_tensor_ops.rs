use tch::Tensor;

#[test]
fn test_basic_tensor_ops() {
    // Create tensors
    let t1 = Tensor::from_slice(&[1.0, 2.0, 3.0]);
    let t2 = Tensor::from_slice(&[4.0, 5.0, 6.0]);
    
    // Perform operations
    let sum = &t1 + &t2;
    let product = &t1 * &t2;
    
    // Verify results
    assert_eq!(sum.size(), [3]);
    assert_eq!(product.size(), [3]);
    
    let expected_sum = [5.0, 7.0, 9.0];
    let expected_product = [4.0, 10.0, 18.0];
    
    for i in 0..3 {
        let i_usize = i as usize;
        let i_i64 = i as i64;
        assert_eq!(sum.double_value(&[i_i64]), expected_sum[i_usize]);
        assert_eq!(product.double_value(&[i_i64]), expected_product[i_usize]);
    }
}