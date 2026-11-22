<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class Week15FeedbackBoundaryTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $student = User::factory()->create([
            'name' => 'Week 15 Boundary Student',
            'role' => 'student',
            'office' => null,
        ]);

        Sanctum::actingAs($student);
    }

    public function test_title_with_exactly_255_characters_is_accepted(): void
    {
        $title = str_repeat('A', 255);

        $response = $this->postJson('/api/feedback', [
            'title' => $title,
            'category' => 'Academic',
            'description' => 'Boundary test for the feedback title.',
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('routing_success', true)
            ->assertJsonPath('feedback.title', $title)
            ->assertJsonPath(
                'feedback.assigned_office',
                'Academic Affairs Office'
            );

        $feedbackId = $response->json('feedback.id');

        $this->assertDatabaseHas('feedback', [
            'id' => $feedbackId,
            'title' => $title,
        ]);

        $this->assertDatabaseCount('feedback', 1);
        $this->assertDatabaseCount('automation_logs', 1);
        $this->assertDatabaseCount('feedback_notifications', 1);
    }

    public function test_description_with_exactly_5000_characters_is_accepted(): void
    {
        $description = str_repeat('B', 5000);

        $response = $this->postJson('/api/feedback', [
            'title' => 'Maximum Description Boundary Test',
            'category' => 'Facilities',
            'description' => $description,
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('routing_success', true)
            ->assertJsonPath('feedback.description', $description)
            ->assertJsonPath(
                'feedback.assigned_office',
                'Facilities Management Office'
            );

        $feedbackId = $response->json('feedback.id');

        $this->assertDatabaseHas('feedback', [
            'id' => $feedbackId,
            'description' => $description,
        ]);

        $this->assertDatabaseCount('feedback', 1);
        $this->assertDatabaseCount('automation_logs', 1);
        $this->assertDatabaseCount('feedback_notifications', 1);
    }
}
