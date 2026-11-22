<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\RateLimiter;
use Tests\TestCase;

class Week15AuthenticationSecurityTest extends TestCase
{
    use RefreshDatabase;

    private const TEST_PASSWORD = 'Week15TestPassword123!';

    private function createStudent(string $email): User
    {
        return User::factory()->create([
            'name' => 'Week 15 Security Student',
            'email' => $email,
            'password' => Hash::make(self::TEST_PASSWORD),
            'role' => 'student',
            'office' => null,
        ]);
    }

    public function test_valid_credentials_allow_login(): void
    {
        $student = $this->createStudent(
            'valid-login@example.test'
        );

        $response = $this->postJson('/api/login', [
            'email' => $student->email,
            'password' => self::TEST_PASSWORD,
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('message', 'Login successful.')
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonPath('expires_in', 28800)
            ->assertJsonPath('user.id', $student->id)
            ->assertJsonPath('user.role', 'student')
            ->assertJsonStructure(['token']);

        $this->assertNotEmpty($response->json('token'));

        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_invalid_password_is_rejected(): void
    {
        $student = $this->createStudent(
            'invalid-password@example.test'
        );

        $response = $this->postJson('/api/login', [
            'email' => $student->email,
            'password' => 'IncorrectPassword123!',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_protected_api_rejects_missing_token(): void
    {
        $this->getJson('/api/me')
            ->assertStatus(401);

        $this->getJson('/api/feedback')
            ->assertStatus(401);
    }

    public function test_logout_revokes_current_api_token(): void
    {
        $student = $this->createStudent(
            'logout-test@example.test'
        );

        $token = $student->createToken(
            'week15-logout-test'
        )->plainTextToken;

        $this->assertDatabaseCount('personal_access_tokens', 1);

        $this->withToken($token)
            ->postJson('/api/logout')
            ->assertStatus(200)
            ->assertJsonPath(
                'message',
                'Logged out successfully.'
            );

        $this->assertDatabaseCount('personal_access_tokens', 0);

        // Clear the test request's cached authentication guards.
        // Subsequent access must authenticate the revoked token again.
        Auth::forgetGuards();

        $this->withToken($token)
            ->getJson('/api/me')
            ->assertStatus(401);
    }

    public function test_expired_token_is_rejected(): void
    {
        $student = $this->createStudent(
            'expired-token@example.test'
        );

        $token = $student->createToken(
            'week15-expired-token',
            ['*'],
            now()->subMinute()
        )->plainTextToken;

        $this->withToken($token)
            ->getJson('/api/me')
            ->assertStatus(401);
    }

    public function test_excessive_failed_logins_are_rate_limited(): void
    {
        $student = $this->createStudent(
            'rate-limit@example.test'
        );

        $key = 'login:' . hash(
            'sha256',
            strtolower($student->email) . '|127.0.0.1'
        );

        RateLimiter::clear($key);

        try {
            // First five incorrect attempts are validation failures.
            for ($attempt = 1; $attempt <= 5; $attempt++) {
                $this->postJson('/api/login', [
                    'email' => $student->email,
                    'password' => 'WrongPassword123!',
                ])->assertStatus(422);
            }

            // Sixth attempt must be blocked.
            $this->postJson('/api/login', [
                'email' => $student->email,
                'password' => 'WrongPassword123!',
            ])
                ->assertStatus(429)
                ->assertJsonPath(
                    'message',
                    'Too many login attempts. Please try again later.'
                );

            $this->assertDatabaseCount(
                'personal_access_tokens',
                0
            );
        } finally {
            // Prevent the test from affecting later test cases.
            RateLimiter::clear($key);
        }
    }
}
