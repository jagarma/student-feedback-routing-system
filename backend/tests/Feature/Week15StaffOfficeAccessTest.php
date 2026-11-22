<?php

namespace Tests\Feature;

use App\Models\Feedback;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class Week15StaffOfficeAccessTest extends TestCase
{
    use RefreshDatabase;

    public function test_staff_can_view_feedback_assigned_to_their_office(): void
    {
        $staff = User::factory()->create([
            'name' => 'Week 15 Academic Staff',
            'role' => 'staff',
            'office' => 'Academic Affairs Office',
        ]);

        $student = User::factory()->create([
            'name' => 'Week 15 Test Student',
            'role' => 'student',
            'office' => null,
        ]);

        $feedback = $this->createFeedback(
            $student,
            'Academic Feedback',
            'Academic',
            'Academic Affairs Office'
        );

        Sanctum::actingAs($staff);

        $this->getJson('/api/feedback/' . $feedback->id)
            ->assertStatus(200)
            ->assertJsonPath('id', $feedback->id)
            ->assertJsonPath(
                'assigned_office',
                'Academic Affairs Office'
            );

        $this->getJson('/api/feedback')
            ->assertStatus(200)
            ->assertJsonCount(1)
            ->assertJsonFragment([
                'title' => 'Academic Feedback',
            ]);
    }

    public function test_staff_cannot_view_feedback_from_another_office(): void
    {
        $staff = User::factory()->create([
            'name' => 'Week 15 Academic Staff',
            'role' => 'staff',
            'office' => 'Academic Affairs Office',
        ]);

        $student = User::factory()->create([
            'name' => 'Week 15 Test Student',
            'role' => 'student',
            'office' => null,
        ]);

        $feedback = $this->createFeedback(
            $student,
            'Facilities Feedback',
            'Facilities',
            'Facilities Management Office'
        );

        Sanctum::actingAs($staff);

        // Direct access to another office's record must fail.
        $this->getJson('/api/feedback/' . $feedback->id)
            ->assertStatus(404);

        // The office feedback list must exclude the record.
        $this->getJson('/api/feedback')
            ->assertStatus(200)
            ->assertJsonCount(0);

        // The original feedback must remain unchanged.
        $this->assertDatabaseHas('feedback', [
            'id' => $feedback->id,
            'assigned_office' => 'Facilities Management Office',
        ]);
    }

    private function createFeedback(
        User $student,
        string $title,
        string $category,
        string $office
    ): Feedback {
        $feedback = new Feedback();

        $feedback->user_id = $student->id;
        $feedback->student_name = $student->name;
        $feedback->title = $title;
        $feedback->category = $category;
        $feedback->description = 'Week 15 office access test.';
        $feedback->assigned_office = $office;
        $feedback->status = 'Pending';

        $feedback->save();

        return $feedback;
    }
}
