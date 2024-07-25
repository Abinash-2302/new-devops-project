document.getElementById('dataForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const name = document.getElementById('name').value;
    const age = document.getElementById('age').value;

    fetch('http://backend:3000/add', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ name, age }),
    })
    .then(response => response.json())
    .then(data => alert('Data saved: ' + JSON.stringify(data)))
    .catch((error) => console.error('Error:', error));
});
