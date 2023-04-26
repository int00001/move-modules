// address :: module name
module 0xCAFE::BasicCoin {
    struct Coin has key {
        value: u64,
    }

    // create Coin struct, store it in an account
    public fun mint(account: signer, value: u64) {
        move_to(&account, Coin { value })
    }
}
