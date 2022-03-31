async function randomPassword() {

    const response = await fetch("/players/random-password");
    return await response.json();

}

async function setRandomPassword(id) {

    const d = await randomPassword();
    document.getElementById(id).value = d.Value;

}