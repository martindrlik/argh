async function loginPlayer(name, password) {

    const response = await fetch("/players/login", {

        method: "post",
        body: JSON.stringify({
            name: name,
            password: password,
        }),

    });
    return await response.json();

}