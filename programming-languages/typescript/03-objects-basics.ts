const user = {
    id: 2,
    name: "Victor",
    email: "victor.antunes@vocovo.com",
    active: true,
};

console.log("Name:", user.name);
console.log("Active", user.active);

user.active = false;
console.log("Updated user:", user);

const product = {
    stockcode: "TWU-144",
    price: 9.99,
};

console.log("Product", product);