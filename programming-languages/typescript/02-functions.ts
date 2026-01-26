function add(x: number, y: number, z: number) {
    return x + y * z;
}

function toUpper(value: string): string {
    return value.toUpperCase();
}

function greet(name: string, title?: string): string {
    if (title) return `Hello, ${title} ${name}`;
    return `Hello, ${name}`;
}

function power(base: number, exponent: number = 2): number {
    return base * exponent;
}

console.log(add(2, 3, 7,));
console.log(toUpper("cloud"));
console.log(greet("Victor"));
console.log(greet("Victor", "Mr"));
console.log(power(3));
console.log(power(3, 3));