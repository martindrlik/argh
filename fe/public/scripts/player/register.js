async function register(name) {

    const response = await fetch("/players/register", {

        method: "post",
        body: JSON.stringify({ name: name }),

    });
    return await response.json();

}