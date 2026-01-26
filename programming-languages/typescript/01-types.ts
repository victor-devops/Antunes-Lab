let a = 10;

let b: number = 20;

let id: number | string = 123;
id = "123";

type Environment = "dev" | "test" | "prod"
let env: Environment = "dev";

console.log({ a, b, id, env });
