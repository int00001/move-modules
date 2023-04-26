// address :: module name
module NamedAddr::BasicCoin {
    use std::signer;

    const MODULE_OWNER: address = @NamedAddr;

    /// error codes
    const ENOT_MODULE_OWNER: u64 = 0;
    const EINSUFFICIENT_BALANCE: u64 = 1;
    const EALREADY_HAS_BALANCE: u64 = 2;

    struct Coin has store {
        value: u64,
    }

    /// struct representing balance of each address
    struct Balance has key {
        coin: Coin
    }

    /// publish empty balance resource under account's address
    /// must be called before minting or transferring to account
    public fun publish_balance(account: &signer) {
        let empty_coin = Coin { value: 0 };
        // require that balance resource does not already exist for address
        assert!(!exists<Balance>(signer::address_of(account)), EALREADY_HAS_BALANCE);
        // move empty coin store to balance under address
        move_to(account, Balance { coin: empty_coin });
    }

    /// mint amount of tokens to mint_addr
    /// mint must be approved by module owner
    public fun mint(module_owner: &signer, mint_addr: address, amount: u64) acquires Balance {
        // require that mint is approved by module owner
        assert!(signer::address_of(module_owner) == MODULE_OWNER, ENOT_MODULE_OWNER);
        // if passed, deposit coin with value amount to mint_addr
        deposit(mint_addr, Coin { value: amount });
    }

    /// returns balance of owner address
    public fun balance_of(owner: address): u64 acquires Balance {
        borrow_global<Balance>(owner).coin.value
    }

    /// transfers amount of tokens
    public fun transfer(from: &signer, to: address, amount: u64) acquires Balance {
        let check = withdraw(signer::address_of(from), amount);
        deposit(to, check);
    }

    fun withdraw(addr: address, amount: u64 ): Coin acquires Balance {
        let balance = balance_of(addr);
        // require that user has balance > amount to withdraw
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        // use global method to get mutable reference to global storage
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        // modify balance
        *balance_ref = balance - amount;
        // return new coin with withdrawn amount
        Coin { value: amount }
    }

    fun deposit(addr: address, check: Coin) acquires Balance {
        let balance = balance_of(addr);
        let balance_ref = &mut borrow_global_mut<Balance>(addr).coin.value;
        let Coin { value } = check;
        *balance_ref = balance + value;
    }

    // unit test
    // takes signer called account with address 0xC0FFEE
    // #[test(account = @0xC0FFEE)]
    // fun test_mint_10(account: signer) acquires Coin {
    //     let addr = 0x1::signer::address_of(&account);
    //     mint(account, 10);

    //     assert!(borrow_global<Coin>(addr).value == 10, 0);
    // }
}
