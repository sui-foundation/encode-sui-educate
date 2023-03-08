module intro_df::capy_car {

    use capy::capy::{Self, Capy};
    use intro_df::car::Car;

    /// Add a dynamic object field of a `Car` (child) to a `Capy` (parent)
    public entry fun ride_car(capy: &mut Capy, car: Car) {
        capy::add_item(capy, car);
    }
    
}