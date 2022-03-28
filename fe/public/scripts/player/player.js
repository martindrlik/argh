async function loadPlayer() {

    const response = await fetch("/players/", {

        method: "get",
        credentials: "same-origin",

    });
    return await response.json();

}