module testing::car_testing {

    use sui::transfer;
    use std::string::{Self, String};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    struct Car has key, store {
        id: UID,
        name: String
    }

    struct CarFactory has key, store {
        id: UID,
        cars_created: u64,
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(
            CarFactory {
                id: object::new(ctx),
                cars_created: 0
            }
        )
    }

    public entry fun create_car(car_factory: &mut CarFactory, car_name: vector<u8>, ctx: &mut TxContext) {
        transfer::transfer(
            Car {
                id: object::new(ctx),
                name: string::utf8(car_name)
            }, tx_context::sender(ctx)
        );

        car_factory.cars_created = car_factory.cars_created + 1;
    }

    public entry fun transfer_car(car: Car, recipient: address) {
        transfer::transfer(car, recipient);
    }

    #[test]
    fun test_car() {

        use sui::test_scenario;
        
        let admin = @0x123;
        let initial_owner = @0x456;
        let final_owner = @0x789;
        
        // tx 1: init module
        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        {
            init(test_scenario::ctx(scenario));
        };

        // tx 2: `initial_owner` creates car
        test_scenario::next_tx(scenario, initial_owner);
        {
            let car_factory = test_scenario::take_shared<CarFactory>(scenario);
            assert!(car_factory.cars_created == 0, 0);
            create_car(&mut car_factory, b"SuiMobile", test_scenario::ctx(scenario));
            assert!(car_factory.cars_created == 1, 0);
            test_scenario::return_shared<CarFactory>(car_factory);
        };

        // tx 3: `initial_owner` transfers car to `final_owner`
        test_scenario::next_tx(scenario, initial_owner);
        {
            let car = test_scenario::take_from_sender<Car>(scenario);
            transfer_car(car, final_owner);
        };

        // tx 4: check to see if `final_owner` has a `Car` by deleting it
        test_scenario::next_tx(scenario, final_owner);
        {
            let car = test_scenario::take_from_sender<Car>(scenario);
            let Car { id, name: _,} = car;
            object::delete(id);
        };

        test_scenario::end(scenario_val);
    }
}