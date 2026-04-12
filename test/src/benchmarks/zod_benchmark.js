import { z } from "zod";

const iterations = 100000;

function benchmark(name, fn) {
    const start = performance.now();

    for (let i = 0; i < iterations; i++) {
        fn();
    }

    const end = performance.now();
    const total = end - start;
    const perOp = (total * 1000) / iterations;

    console.log(`
📊 ${name}
Total: ${total.toFixed(2)} ms
Per op: ${perOp.toFixed(4)} µs
Ops/sec: ${(1000000 / perOp).toFixed(0)}
`);
}

// -----------------------------
// Primitive valid
// -----------------------------
const stringSchema = z.string().min(3);

benchmark("Zod - String valid", () => {
    stringSchema.parse("hello");
});

// -----------------------------
// Primitive invalid
// -----------------------------
const invalidSchema = z.string().min(10);

benchmark("Zod - String invalid", () => {
    try {
        invalidSchema.parse("hi");
    } catch { }
});

// -----------------------------
// Small object
// -----------------------------
const small = z.object({
    name: z.string(),
    age: z.number(),
});

benchmark("Zod - Small object", () => {
    small.parse({ name: "John", age: 30 });
});

// -----------------------------
// Medium object
// -----------------------------
const medium = z.object({
    name: z.string(),
    email: z.string().email(),
    age: z.number().min(18),
    active: z.boolean(),
    tags: z.array(z.string()),
});

benchmark("Zod - Medium object", () => {
    medium.parse({
        name: "John",
        email: "john@example.com",
        age: 30,
        active: true,
        tags: ["dart", "flutter"],
    });
});

// -----------------------------
// Complex object
// -----------------------------
const complex = z.object({
    user: z.object({
        name: z.string(),
        email: z.string().email(),
        age: z.number(),
    }),
    orders: z.array(
        z.object({
            id: z.string(),
            price: z.number(),
            quantity: z.number(),
        })
    ),
});

const complexData = {
    user: {
        name: "John",
        email: "john@example.com",
        age: 30,
    },
    orders: Array.from({ length: 5 }).map((_, i) => ({
        id: `${i}`,
        price: 10.5,
        quantity: 2,
    })),
};

benchmark("Zod - Complex object", () => {
    complex.parse(complexData);
});

// -----------------------------
// Transform
// -----------------------------
const transformSchema = z.string().transform(v => v.toUpperCase());

benchmark("Zod - Transform", () => {
    transformSchema.parse("hello");
});

// -----------------------------
// Default
// -----------------------------
const defaultSchema = z.number().default(10);

benchmark("Zod - Default", () => {
    defaultSchema.parse(undefined);
});

// -----------------------------
// Nullable
// -----------------------------
const nullableSchema = z.string().nullable();

benchmark("Zod - Nullable", () => {
    nullableSchema.parse(null);
});

// -----------------------------
// Union
// -----------------------------
const unionSchema = z.union([z.string(), z.number()]);

benchmark("Zod - Union (string)", () => {
    unionSchema.parse("hello");
});

benchmark("Zod - Union (int)", () => {
    unionSchema.parse(10);
});

// -----------------------------
// safeParse
// -----------------------------
benchmark("Zod - safeParse", () => {
    small.safeParse({ name: "John", age: 30 });
});