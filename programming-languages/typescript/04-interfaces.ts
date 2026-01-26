interface User {
    id: number;
    name: string;
    email: string | number;
    active: boolean;
}

function printUser(u: User): void {
    console.log(`User #${u.id}: ${u.name} (${u.email}) active=${u.active}`)
}

const a: User = {
    id: 1,
    name: "Victor",
    email: "victor@",
    active: true,
};

printUser(a);