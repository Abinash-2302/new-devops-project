document.getElementById('dataForm').addEventListener('submit', async function(event) {
    event.preventDefault();
    const data = document.getElementById('dataInput').value;
    
    try {
        const response = await fetch( 'http://localhost:3000/api/data', {
	            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ data: data })
        });
        if (response.ok) {
            alert('Data submitted successfully!');
        } else {
            alert('Failed to submit data.');
        }
    } catch (error) {
        console.error('Error:', error);
    }
});
