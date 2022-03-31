async function registerPlayer(p) {

    const response = await fetch("/players/register", {

        method: "post",
        body: JSON.stringify(p),

    });
    return await response.json();

}