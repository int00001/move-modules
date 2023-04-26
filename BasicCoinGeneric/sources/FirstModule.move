
/// define a module with generics that can be reused for different coins
/// e.g.
/// let btc_coin = Coin<BTC> { value: 100 };
/// let eth_coin = Coin<ETH> { value: 200 };

// address :: module name
module NamedAddr::BasicCoin {
    use std::signer;

    const MODULE_OWNER: address = @NamedAddr;

    /// error codes
    const ENOT_MODULE_OWNER: u64 = 0;
    const EINSUFFICIENT_BALANCE: u64 = 1;
    const EALREADY_HAS_BALANCE: u64 = 2;

    struct Coin<phantom CoinType> has store {
        value: u64,
    }

    /// struct representing balance of each address
    struct Balance<phantom CoinType> has key {
        coin: Coin<CoinType>
    }

    /// publish empty balance resource under account's address
    /// must be called before minting or transferring to account
    public fun publish_balance<CoinType>(account: &signer) {
        let empty_coin = Coin<CoinType> { value: 0 };
        // require that balance resource does not already exist for address
        assert!(!exists<Balance<CoinType>>(signer::address_of(account)), EALREADY_HAS_BALANCE);
        // move empty coin store to balance under address
        move_to(account, Balance<CoinType> { coin: empty_coin });
    }

    /// mint amount of tokens to mint_addr
    /// requires a witness with CoinType so that module that owns CoinType can decide minting policy
    public fun mint<CoinType: drop>(mint_addr: address, amount: u64, _witness: CoinType) acquires Balance {
        // if passed, deposit coin with value amount to mint_addr
        deposit(mint_addr, Coin<CoinType> { value: amount });
    }

    /// returns balance of owner address
    public fun balance_of<CoinType>(owner: address): u64 acquires Balance {
        borrow_global<Balance<CoinType>>(owner).coin.value
    }

    /// transfers amount of tokens
    public fun transfer<CoinType: drop>(from: &signer, to: address, amount: u64, _witness: CoinType) acquires Balance {
        let check = withdraw<CoinType>(signer::address_of(from), amount);
        deposit<CoinType>(to, check);
    }

    fun withdraw<CoinType>(addr: address, amount: u64 ): Coin<CoinType> acquires Balance {
        let balance = balance_of<CoinType>(addr);
        // require that user has balance > amount to withdraw
        assert!(balance >= amount, EINSUFFICIENT_BALANCE);
        // use global method to get mutable reference to global storage
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        // modify balance
        *balance_ref = balance - amount;
        // return new coin with withdrawn amount
        Coin { value: amount }
    }

    fun deposit<CoinType>(addr: address, check: Coin<CoinType>) acquires Balance {
        let balance = balance_of<CoinType>(addr);
        let balance_ref = &mut borrow_global_mut<Balance<CoinType>>(addr).coin.value;
        let Coin { value } = check;
        *balance_ref = balance + value;
    }
}
