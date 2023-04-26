// address :: module name
module 0xCAFE::BasicCoin {
    struct Coin has key {
        value: u64,
    }

    // create Coin struct, store it in an account
    public fun mint(account: signer, value: u64) {
        move_to(&account, Coin { value })
    }

    // unit test
    // takes signer called account with address 0xC0FFEE
    #[test(account = @0xC0FFEE)]
    fun test_mint_10(account: signer) acquires Coin {
        let addr = 0x1::signer::address_of(&account);
        mint(account, 10);

        assert!(borrow_global<Coin>(addr).value == 10, 0);
    }
}
