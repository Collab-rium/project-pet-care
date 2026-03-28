/// API Configuration for Pet Care App
/// Configure for development, testing, or production

// Local development (your laptop)
const String apiBaseUrlLocal = 'http://localhost:4000';

// Android emulator (10.0.2.2 is localhost inside Android)
const String apiBaseUrlAndroidLocal = 'http://10.0.2.2:4000';

// Production (Firebase Cloud Functions)
// Set this when deploying to Firebase
// Example: 'https://your-project-abcd1234.run.app'
const String apiBaseUrlProduction = 'http://localhost:4000'; // Change this!

// Use this to switch between mock and real API
const bool useMockApi = false;

// Use this to switch between local and production backend
const bool useProductionBackend = false;

/// Get the appropriate base URL
String getApiBaseUrl() {
  if (useProductionBackend) {
    return apiBaseUrlProduction;
  }
  
  // For local development, use Android emulator URL if needed
  // Detectplatform and return appropriate URL
  return apiBaseUrlLocal;
}

const String API_BASE_URL = apiBaseUrlLocal;
