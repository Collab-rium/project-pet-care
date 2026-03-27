/// API Configuration for Pet Care App
/// Switch USE_MOCK_API to false to use real backend

const String apiBaseUrl = 'http://localhost:4000';

// For Android emulator (10.0.2.2 is localhost inside Android)
const String apiBaseUrlAndroid = 'http://10.0.2.2:4000';

/// Set to false to use real backend
const bool useMockApi = true;

/// Get the appropriate base URL based on platform
String getApiBaseUrl() {
  // In a real app, you'd detect platform here
  // For now, use localhost (works in web/desktop)
  return apiBaseUrl;
}
