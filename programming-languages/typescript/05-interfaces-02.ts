interface UserInput {
    id: number;
    email?: string;
}

function getEmailLowercase(input: UserInput): string {
    const email = input.email ?? "unknown";
    return email.toLowerCase();
}

const x: UserInput = {
    id: 1,
    email: "Victor@vocovo.com"
};

const y: UserInput = {
    id: 2,
};

console.log(getEmailLowercase(x));
console.log(getEmailLowercase(y));

