use super::{FlagData, FlagDataBase, FlagDataExecute};
use crate::Integer;

pub struct Bool;

impl<D: Integer> FlagDataExecute<D> for FlagData<Bool, D> {
    const ID_STR: &'static str = "bool";
    const FLAG_SIZE: usize = D::BITS as usize;
    const INIT_VALUE: D = D::ONE;
    const BITS: usize = D::BITS;

    #[inline]
    fn new(size: usize) -> Self {
        Self::allocate((size + 1) / 2)
    }

    #[inline]
    fn fall_through(data: &mut [D], start: usize, interval: usize) {
        let mut i = start;

        let limit = data.len().saturating_sub(interval * 3);
        while i < limit {
            unsafe {
                *data.get_unchecked_mut(i) = D::ZERO;
                *data.get_unchecked_mut(i + interval) = D::ZERO;
                *data.get_unchecked_mut(i + interval * 2) = D::ZERO;
                *data.get_unchecked_mut(i + interval * 3) = D::ZERO;
            }
            i += interval * 4;
        }

        while i < data.len() {
            unsafe {
                *data.get_unchecked_mut(i) = D::ZERO;
            }
            i += interval;
        }
    }

    fn is_prime(&self, index: usize) -> bool {
        self.0[index] != D::ZERO
    }

    fn flag_count(&self) -> usize {
        self.0.len()
    }

    fn count_primes(&self, _: usize) -> usize {
        self.0.iter().map(|n| n.count_ones()).sum()
    }
}
