# Auth
1. Domain Layer Tests
	Use Cases Tests (usecases)
		- LoginUser - test login logic với các scenarios
		- RegisterUser - test registration logic
		- ForgotPassword - test forgot password flow
		- ResetPassword - test password reset
		- VerifyOtp - test OTP verification
		- VerifyEmail - test email verification
		- CheckEmail - test email availability check
		- SendMail - test sending verification emails
		- ChangePassword - test password change
		- UpdateUserInfo - test user profile updates
		- UpdateJobInfo - test job information updates
		- GetUserData - test fetching user data
		- LogOut - test logout functionality
		- UpdateSearchableCandidate - test searchable status toggle
		- UpdateEmailNotification - test email notification preferences
		- GetUniversityUseCase - test fetching universities
2. Data Layer Tests
Repository Implementation Tests (repositories)
AuthRepositoryImpl - test tất cả methods với:
Success scenarios
Error handling (DioException, PlatformException)
Token management
Data transformation
Data Source Tests (datasources)
AuthRemoteDataSource - test API calls
Mock HTTP responses
Test error scenarios
Model Tests (test/unit/features/auth/data/models/)
UserModel và các submodels - test JSON serialization/deserialization
Test mapper methods (toEntity(), fromJson(), toJson())
Test với invalid JSON data
3. Presentation Layer Tests
Provider Tests (test/unit/features/auth/presentation/providers/)
AuthProvider - test state management với:
State transitions
Error handling
Loading states
Success scenarios