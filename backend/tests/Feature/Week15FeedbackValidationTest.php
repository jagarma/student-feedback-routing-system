<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class Week15FeedbackValidationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $student = User::factory()->create([
            'name' => 'Week 15 Validation Student',
            'role' => 'student',
            'office' => null,
        ]);

        Sanctum::actingAs($student);
    }

    public function test_missing_title_is_rejected(): void
    {
        $this->assertInvalidSubmission(
            [
                'category' => 'Academic',
                'description' => 'Feedback without a title.',
            ],
            'title'
        );
    }

    public function test_invalid_category_is_rejected(): void
    {
        $this->assertInvalidSubmission(
            [
                'title' => 'Invalid Category Test',
                'category' => 'Unknown Category',
                'description' => 'This category must be rejected.',
            ],
            'category'
        );
    }

    public function test_title_over_255_characters_is_rejected(): void
    {
        $this->assertInvalidSubmission(
            [
                'title' => str_repeat('A', 256),
                'category' => 'Academic',
                'description' => 'Testing the maximum title length.',
            ],
            'title'
        );
    }

    public function test_description_over_5000_characters_is_rejected(): void
    {
        $this->assertInvalidSubmission(
            [
                'title' => 'Description Boundary Test',
                'category' => 'Academic',
                'description' => str_repeat('B', 5001),
            ],
            'description'
        );
    }

    private function assertInvalidSubmission(
        array $payload,
        string $invalidField
    ): void {
        $response = $this->postJson('/api/feedback', $payload);

        $response->assertStatus(422)
            ->assertJsonValidationErrors([$invalidField]);

        // Invalid feedback must not create any records.
        $this->assertDatabaseCount('feedback', 0);
        $this->assertDatabaseCount('automation_logs', 0);
        $this->assertDatabaseCount('feedback_notifications', 0);
    }
}
