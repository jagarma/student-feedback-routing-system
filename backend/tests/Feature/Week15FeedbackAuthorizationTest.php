<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class Week15FeedbackAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    public function test_staff_cannot_submit_student_feedback(): void
    {
        $staff = User::factory()->create([
            'name' => 'Week 15 Academic Staff',
            'email' => 'week15.staff@example.test',
            'role' => 'staff',
            'office' => 'Academic Affairs Office',
        ]);

        Sanctum::actingAs($staff);

        $response = $this->postJson('/api/feedback', [
            'title' => 'Unauthorized Staff Submission',
            'category' => 'Academic',
            'description' => 'Staff accounts must not submit student feedback.',
        ]);

        $response->assertStatus(403)
            ->assertJsonPath(
                'message',
                'Only students can submit feedback.'
            );

        $this->assertDatabaseCount('feedback', 0);
        $this->assertDatabaseCount('automation_logs', 0);
        $this->assertDatabaseCount('feedback_notifications', 0);
    }

    public function test_unauthenticated_user_cannot_submit_feedback(): void
    {
        $response = $this->postJson('/api/feedback', [
            'title' => 'Anonymous Submission',
            'category' => 'Academic',
            'description' => 'Anonymous requests must be rejected.',
        ]);

        $response->assertStatus(401);

        $this->assertDatabaseCount('feedback', 0);
        $this->assertDatabaseCount('automation_logs', 0);
        $this->assertDatabaseCount('feedback_notifications', 0);
    }
}
