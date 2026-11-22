<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class Week15FeedbackSubmissionTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_student_can_submit_and_route_academic_feedback(): void
    {
        $student = User::factory()->create([
            'name' => 'Week 15 Test Student',
            'email' => 'week15.student@example.test',
            'role' => 'student',
            'office' => null,
        ]);

        Sanctum::actingAs($student);

        $response = $this->postJson('/api/feedback', [
            'title' => 'Week 15 Academic Feedback',
            'category' => 'Academic',
            'description' => 'Testing automatic academic feedback routing.',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('routing_success', true)
            ->assertJsonPath(
                'feedback.student_name',
                'Week 15 Test Student'
            )
            ->assertJsonPath(
                'feedback.category',
                'Academic'
            )
            ->assertJsonPath(
                'feedback.assigned_office',
                'Academic Affairs Office'
            )
            ->assertJsonPath(
                'feedback.status',
                'Pending'
            );

        $feedbackId = $response->json('feedback.id');

        $this->assertNotNull($feedbackId);

        $this->assertDatabaseHas('feedback', [
            'id' => $feedbackId,
            'user_id' => $student->id,
            'student_name' => 'Week 15 Test Student',
            'title' => 'Week 15 Academic Feedback',
            'category' => 'Academic',
            'assigned_office' => 'Academic Affairs Office',
            'status' => 'Pending',
        ]);

        $this->assertDatabaseHas('automation_logs', [
            'feedback_id' => $feedbackId,
            'action' => 'Automatic Feedback Routing',
            'status' => 'Success',
            'retry_count' => 0,
            'max_retries' => 3,
            'requires_manual_review' => false,
        ]);

        $this->assertDatabaseHas('feedback_notifications', [
            'feedback_id' => $feedbackId,
            'recipient_office' => 'Academic Affairs Office',
            'notification_type' => 'Assignment',
            'status' => 'Unread',
        ]);

        $this->assertDatabaseCount('feedback', 1);
        $this->assertDatabaseCount('automation_logs', 1);
        $this->assertDatabaseCount('feedback_notifications', 1);
    }
}
