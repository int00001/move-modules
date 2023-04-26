/// implementing an OddCoin module that uses BasicCoin generic methods
/// for a custom coin implementation

module NamedAddr::OddCoin {
    use std::signer;
    use NamedAddr::BasicCoin;

    struct OddCoin has drop {}

    const ENOT_ODD: u64 = 0;

    public fun setup_and_mint(account: &signer, amount: u64) {
        BasicCoin::publish_balance<OddCoin>(account);
        BasicCoin::mint<OddCoin>(signer::address_of(account), amount, OddCoin {});
    }

    public fun transfer(from: &signer, to: address, amount: u64) {
        assert!(amount % 2 == 1, ENOT_ODD);
        BasicCoin::transfer<OddCoin>(from, to, amount, OddCoin {});
    }

    // unit tests

    #[test(from = @0x1, to = @0x2)]
    fun test_odd_success(from: signer, to: signer) {
        setup_and_mint(&from, 15);
        setup_and_mint(&to, 10);

        transfer(&from, @0x2, 7);

        assert!(BasicCoin::balance_of<OddCoin>(@0x1) == 8, 0);
        assert!(BasicCoin::balance_of<OddCoin>(@0x2) == 17, 0);
    }

    #[test(from = @0x1, to = @0x2)]
    #[expected_failure(abort_code = ENOT_ODD)]
    fun test_odd_failure(from: signer, to: signer) {
        setup_and_mint(&from, 15);
        setup_and_mint(&to, 10);

        // even transfer should fail
        transfer(&from, @0x1, 8);
    }
}