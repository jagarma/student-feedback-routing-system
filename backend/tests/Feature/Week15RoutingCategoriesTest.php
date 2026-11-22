<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class Week15RoutingCategoriesTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $student = User::factory()->create([
            'name' => 'Week 15 Routing Student',
            'role' => 'student',
            'office' => null,
        ]);

        Sanctum::actingAs($student);
    }

    public function test_academic_feedback_routes_correctly(): void
    {
        $this->assertCategoryRoutesToOffice(
            'Academic',
            'Academic Affairs Office'
        );
    }

    public function test_facilities_feedback_routes_correctly(): void
    {
        $this->assertCategoryRoutesToOffice(
            'Facilities',
            'Facilities Management Office'
        );
    }

    public function test_student_services_feedback_routes_correctly(): void
    {
        $this->assertCategoryRoutesToOffice(
            'Student Services',
            'Student Services Office'
        );
    }

    public function test_others_feedback_routes_correctly(): void
    {
        $this->assertCategoryRoutesToOffice(
            'Others',
            'General Administration Office'
        );
    }

    private function assertCategoryRoutesToOffice(
        string $category,
        string $office
    ): void {
        $response = $this->postJson('/api/feedback', [
            'title' => 'Week 15 ' . $category . ' Routing Test',
            'category' => $category,
            'description' => 'Verify automatic routing to the correct office.',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('routing_success', true)
            ->assertJsonPath('feedback.category', $category)
            ->assertJsonPath('feedback.assigned_office', $office)
            ->assertJsonPath('feedback.status', 'Pending');

        $feedbackId = $response->json('feedback.id');

        $this->assertNotNull($feedbackId);

        $this->assertDatabaseHas('feedback', [
            'id' => $feedbackId,
            'category' => $category,
            'assigned_office' => $office,
        ]);

        $this->assertDatabaseHas('automation_logs', [
            'feedback_id' => $feedbackId,
            'action' => 'Automatic Feedback Routing',
            'status' => 'Success',
        ]);

        $this->assertDatabaseHas('feedback_notifications', [
            'feedback_id' => $feedbackId,
            'recipient_office' => $office,
            'notification_type' => 'Assignment',
            'status' => 'Unread',
        ]);

        $this->assertDatabaseCount('feedback', 1);
        $this->assertDatabaseCount('automation_logs', 1);
        $this->assertDatabaseCount('feedback_notifications', 1);
    }
}
