import structs/HashMap
import io/File

import gifnooc/Errors

SerializationEntry: class <T> {
    serialize: Func(T) -> String
    deserialize: Func(String) -> T
    validateValue: Func(T) -> Bool
    validateString: Func(String) -> Bool
    
    init: func (=serialize, =deserialize, =validateValue, =validateString) {}
}

Registrar: class {
    entries: static HashMap<Class, SerializationEntry> = HashMap<Class, SerializationEntry> new()

    // Now this is a beast.
    addEntry: static func <T> (T: Class, serialize: Func(T) -> String, deserialize: Func(String) -> T, validateValue: Func(T) -> Bool, validateString: Func(String) -> Bool) {
        This entries put(T, SerializationEntry<T> new(serialize, deserialize, validateValue, validateString))
    }

    getEntry: static func <T> (T: Class) -> SerializationEntry<T> {
        entry := This entries get(T)
        if(entry == null) {
            SerializationError new(This, "No serialization This entries found for %s." format(T name)) throw()
        }
        return entry
    }

    serialize: static func <T> (T: Class, value: T) -> String {
        if(!validateValue(T, value)) {
            SerializationError new(This, "The '%s' object at 0x%x could not be validated." format(T name, value as Pointer)) throw()
        }
        getEntry(T) serialize(value as T)
    }

    deserialize: static func <T> (T: Class, value: String) -> T {
        if(!validateString(T, value)) {
            SerializationError new(This, "The string '%s' could not be validated for %s." format(value, T name)) throw()
        }
        fnc := getEntry(T) deserialize as Func(String) -> Pointer
        return fnc(value)
    }

    validateString: static func <T> (T: Class, value: String) -> Bool {
        fnc := getEntry(T) validateString as Func(String) -> Bool
        return fnc(value)
    }

    validateValue: static func <T> (T: Class, value: T) -> Bool {
        getEntry(T) validateValue(value as T)
    }
}

// Built-in entries
Registrar addEntry(Int, \
    func (value: Int) -> String { value toString() }, \
    func (value: String) -> Int { value toInt() },
    func (value: Int) -> Bool { true },
    func (value: String) -> Bool { true /* TODO. */ })
    
Registrar addEntry(Bool, \
    func (value: Bool) -> String { value ? "yes" : "no" }, \
    func (value: String) -> Bool { value == "yes" },
    func (value: Bool) -> Bool { true },
    func (value: String) -> Bool { value == "yes" || value == "no" })
    
Registrar addEntry(String, \
    func (value: String) -> String { value }, \
    func (value: String) -> String { value },
    func (value: String) -> Bool { true },
    func (value: String) -> Bool { true })
    
Registrar addEntry(File, \
    func (value: File) -> String { value path }, \
    func (value: String) -> File { File new(value) },
    func (value: File) -> Bool { true },
    func (value: String) -> Bool { true })

