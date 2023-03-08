module intro_df::intro_df {

    use sui::object::UID;

    use sui::dynamic_field as field;
    use sui::dynamic_object_field as ofield;

    // Parent struct
    struct Parent has key {
        id: UID,
    }

    // Dynamic field child struct type containing a counter
    struct DFChild has store {
        count: u64
    }

    // Dynamic object field child struct type containing a counter
    struct DOFChild has key, store {
        id: UID,
        count: u64,
    }

    // Adds a DFChild to the parent object under the provided name
    public fun add_dfchild(parent: &mut Parent, child: DFChild, name: vector<u8>) {
        field::add(&mut parent.id, name, child);
    }

    // Adds a DOFChild to the parent object under the provided name
    public entry fun add_dofchild(parent: &mut Parent, child: DOFChild, name: vector<u8>) {
        ofield::add(&mut parent.id, name, child);
    }

    // Accessing and mutating a dynamic field

    // Mutate a DOFChild directly
    public entry fun mutate_dofchild(child: &mut DOFChild) {
        child.count = child.count + 1;
    }

    // Mutate a DFChild directly
    public fun mutate_dfchild(child: &mut DFChild) {
        child.count = child.count + 1;
    }

    // Mutate a DFChild's counter via its parent object
    public entry fun mutate_dfchild_via_parent(parent: &mut Parent, child_name: vector<u8>) {
        let child = field::borrow_mut<vector<u8>, DFChild>(&mut parent.id, child_name);
        child.count = child.count + 1;
    }

    // Mutate a DOFChild's counter via its parent object
    public entry fun mutate_dofchild_via_parent(parent: &mut Parent, child_name: vector<u8>) {
        mutate_dofchild(ofield::borrow_mut<vector<u8>, DOFChild>(
            &mut parent.id,
            child_name,
        ));
    }

    // Complete example here: https://github.com/sui-foundation/sui-move-intro-course/blob/main/unit-four/lessons/2_dynamic_fields.md

}