import * as yup from "yup";

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

// Primitive
const stringSchema = yup.string().min(3);

benchmark("Yup - String valid", () => {
    stringSchema.validateSync("hello");
});

// Invalid
benchmark("Yup - String invalid", () => {
    try {
        stringSchema.validateSync("hi");
    } catch { }
});

// Small object
const small = yup.object({
    name: yup.string().required(),
    age: yup.number().required(),
});

benchmark("Yup - Small object", () => {
    small.validateSync({ name: "John", age: 30 });
});

// Medium
const medium = yup.object({
    name: yup.string(),
    email: yup.string().email(),
    age: yup.number().min(18),
    active: yup.boolean(),
    tags: yup.array(yup.string()),
});

benchmark("Yup - Medium object", () => {
    medium.validateSync({
        name: "John",
        email: "john@example.com",
        age: 30,
        active: true,
        tags: ["dart", "flutter"],
    });
});

// Complex
const complex = yup.object({
    user: yup.object({
        name: yup.string(),
        email: yup.string().email(),
        age: yup.number(),
    }),
    orders: yup.array(
        yup.object({
            id: yup.string(),
            price: yup.number(),
            quantity: yup.number(),
        })
    ),
});

benchmark("Yup - Complex object", () => {
    complex.validateSync({
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
    });
});