module intro_df::car {

    use sui::transfer;
    use sui::url::{Self, Url};
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::dynamic_object_field as ofield;

    struct Car has key, store {
        id: UID,
        stats: Stats,
    }

    struct Stats has store {
        speed: u8,
        acceleration: u8,
        handling: u8
    }

    struct Decal has key, store {
        id: UID,
        url: Url
    }

    public entry fun create_car(ctx: &mut TxContext) {
        let car = Car {
            id: object::new(ctx),
            stats: Stats {
                speed: 50,
                acceleration: 50,
                handling: 50
            }
        };
        transfer::transfer(car, tx_context::sender(ctx));
    }

    public entry fun create_decal(url: vector<u8>, ctx: &mut TxContext) {
        let decal = Decal {
            id: object::new(ctx),
            url: url::new_unsafe_from_bytes(url)
        };
        transfer::transfer(decal, tx_context::sender(ctx));
    }

    public entry fun add_decal(car: &mut Car, decal: Decal) {
        let decal_id = object::id(&decal);
        ofield::add(&mut car.id, decal_id, decal);
    }

    public fun get_url_via_child(decal: &Decal): Url {
        decal.url
    }

    public fun get_url_via_parent(car: &Car, decal_id: ID): Url {
        // ofield::borrow<Name: copy + drop + store, Value: key + store>(object: &UID, name: Name): Value { ... }
        get_url_via_child(ofield::borrow<ID, Decal>(&car.id, decal_id))
    }
}