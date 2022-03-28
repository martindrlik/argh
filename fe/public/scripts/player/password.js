async function randomPassword() {

    const response = await fetch("/players/random-password");
    return await response.json();

}