// Test the /auth/firebase endpoint
async function testFirebaseAuth() {
  try {
    console.log('Testing /auth/firebase endpoint...');

    // For now, let's just test the endpoint structure by making a request without auth
    // This should fail with 401, but we can see the response structure
    const response = await fetch('http://localhost:8080/api/v1/auth/firebase', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        idToken: 'test-token'
      })
    });

    const data = await response.json();

    console.log('Response:', data);
    console.log('Response status:', response.status);
    console.log('Response headers:', Object.fromEntries(response.headers.entries()));

  } catch (error) {
    console.log('Error:', error.message);
  }
}

testFirebaseAuth();