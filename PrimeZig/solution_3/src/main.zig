const std = @import("std");

// sieves
const sieves = @import("sieves.zig");
const IntSieve = sieves.IntSieve;
const BitSieve = sieves.BitSieve;
const VecSieve = sieves.VecSieve;

// runners
const runners = @import("runners.zig");
const SingleThreadedRunner = runners.SingleThreadedRunner;
const ParallelAmdahlRunner = runners.AmdahlRunner;
const ParallelGustafsonRunner = runners.GustafsonRunner;

// allocators
const allocators = @import("alloc.zig");
const c_std_lib = @import("alloc.zig").c_std_lib;
const VAlloc = allocators.VAlloc;
const CAlloc = allocators.CAlloc;
const SAlloc = allocators.SAlloc;

const SIZE = 1_000_000;

var scratchpad: [SIZE]u8 align(std.mem.page_size) = undefined;

pub fn main() anyerror!void {
    const run_for = 5; // Seconds

    // check for the --all flag.
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    const all = (args.len == 2) and (std.mem.eql(u8, args[1], "--all"));

    const NonClearing = SAlloc(c_std_lib, .{.should_clear = false});

    comptime const specs = .{
        // single-threaded.
        .{ SingleThreadedRunner, .{}, IntSieve, .{}, true},
        .{ SingleThreadedRunner, .{}, IntSieve, .{.wheel_primes = 6}, true},
        .{ SingleThreadedRunner, .{}, BitSieve, .{.RunFactorChunk = u64}, false},
        .{ SingleThreadedRunner, .{}, BitSieve, .{.RunFactorChunk = u64, .FindFactorChunk = u32}, true}, // equivalent to C
        // best singlethreaded base runner
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32}, true},
        // pessimizations on singlethreadedness (base)
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u32, .FindFactorChunk = u32}, false}, // different RunFactorChunks
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u8, .FindFactorChunk = u32}, false}, // different RunFactorChunks
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32, .max_vector = 2}, false}, // vectorizations on u64
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32, .max_vector = 4}, false}, // vectorizations on u64
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32, .max_vector = 8}, false}, // vectorizations on u64
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u32, .FindFactorChunk = u32, .max_vector = 4}, false}, // vectorizations on u32
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u32, .FindFactorChunk = u32, .max_vector = 8}, false}, // vectorizations on u32
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u32, .FindFactorChunk = u32, .max_vector = 16}, false}, // vectorizations on u32
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u8, .FindFactorChunk = u32, .max_vector = 8}, false}, // vectorizations on u8
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u8, .FindFactorChunk = u32, .max_vector = 16}, false}, // vectorizations on u8
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u8, .FindFactorChunk = u32, .max_vector = 64}, false}, // vectorizations on u8
        // best singlethreaded wheel runner:
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32, .wheel_primes = 5, .allocator = NonClearing}, true},
        // pessimizations on singlethreadedeness (wheel)
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32, .wheel_primes = 5, .note = "-calloc"}, false},  // using calloc
        .{ SingleThreadedRunner, .{}, BitSieve, .{.PRIME = 1, .unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u8, .wheel_primes = 5, .allocator = NonClearing}, false}, // inverted
        .{ SingleThreadedRunner, .{}, BitSieve, .{.PRIME = 1, .unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u8, .find_factor = .advanced, .wheel_primes = 5, .allocator = NonClearing}, false}, // trying to use find_factor algo
        .{ SingleThreadedRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u8, .find_factor = .advanced, .wheel_primes = 5, .allocator = NonClearing}, false},
        // experimental vector sieve (typically less performant than unrolled bitsieve)
        .{ SingleThreadedRunner, .{}, VecSieve, .{.PRIME = 1, .allocator = SAlloc(c_std_lib, .{})}, true},
        // multi-threaded
        .{ ParallelAmdahlRunner, .{}, IntSieve, .{}, true},
        .{ ParallelGustafsonRunner, .{}, IntSieve, .{}, true},
        .{ ParallelGustafsonRunner, .{}, IntSieve, .{.wheel_primes = 6}, true},
        .{ ParallelGustafsonRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32}, true},
        .{ ParallelGustafsonRunner, .{.no_ht = true}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32}, false},
        // in testing we find that the best performing of the following four is architecture-dependent
        .{ ParallelGustafsonRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32, .wheel_primes = 2, .allocator = NonClearing}, true},
        .{ ParallelGustafsonRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32, .wheel_primes = 3, .allocator = NonClearing}, true},
        .{ ParallelGustafsonRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32, .wheel_primes = 4, .allocator = NonClearing}, true},
        .{ ParallelGustafsonRunner, .{}, BitSieve, .{.unrolled = true, .RunFactorChunk = u64, .FindFactorChunk = u32, .wheel_primes = 5, .allocator = NonClearing}, true},
    };

    inline for (specs) |spec| {
        comptime const RunnerFn = spec[0];
        comptime const runner_opts = spec[1];
        comptime const SieveFn = spec[2];
        comptime const sieve_opts = spec[3];

        comptime const Sieve = SieveFn(sieve_opts);
        comptime const Runner = RunnerFn(Sieve, runner_opts);
        comptime const should_run = spec[4];

        if (should_run) {
            try runSieveTest(Runner, run_for, SIZE);
        } else {
            if (all) {
                try runSieveTest(Runner, run_for, SIZE);
            }
        }
    }
}

fn runSieveTest(
    comptime Runner: type,
    run_for: comptime_int,
    sieve_size: usize,
) anyerror!void {
    @setAlignStack(256);
    const timer = try std.time.Timer.start();
    var passes: u64 = 0;

    var runner = try Runner.init(sieve_size, &passes);
    defer runner.deinit();

    while (timer.read() < run_for * std.time.ns_per_s) {
        try runner.sieveInit();
        defer runner.sieveDeinit();
        runner.run();
    }

    const elapsed = timer.read();

    var threads = try Runner.threads();

    try printResults(
        "ManDeJan&ityonemo&SpexGuy-zig-" ++ Runner.name,
        passes,
        elapsed,
        threads,
        Runner.algo,
        Runner.bits);
}

fn printResults(backing: []const u8, passes: usize, elapsed_ns: u64, threads: usize, algo: []const u8, bits: usize) !void {
    const elapsed = @intToFloat(f32, elapsed_ns) / @intToFloat(f32, std.time.ns_per_s);
    const stdout = std.io.getStdOut().writer();

    try stdout.print("{s};{};{d:.5};{};faithful=yes,algorithm={s},bits={}\n", .{ backing, passes, elapsed, threads, algo, bits });
}
