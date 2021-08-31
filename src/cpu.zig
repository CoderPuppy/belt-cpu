/// This struct 'cpu' stores the physical implementation of the cpu and it's current state.
pub const CPU = struct {
    belt: [8]u16,       // the belt inside the cpu
    pipeline: [3]u16,   // the pipeline storing instructions
    pc: u16,            // the program counter
    mem: [65536]u16,    // memory 16bit (65536 words)

    pub fn init() CPU {
        return CPU {
            .belt = undefined,
            .pipeline = undefined,
            .pc = 0,
            .mem = undefined,
        };
    }

    pub fn init_mem(mem: [65536]u16) CPU {
        return CPU {
            .belt = undefined,
            .pipeline = undefined,
            .pc = 0,
            .mem = mem,
        };
    }
};