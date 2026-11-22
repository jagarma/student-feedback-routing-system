<?php

namespace Tests\Feature;

use App\Models\Feedback;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class Week15StudentDataIsolationTest extends TestCase
{
    use RefreshDatabase;

    public function test_student_cannot_view_another_students_feedback(): void
    {
        $studentOne = User::factory()->create([
            'name' => 'Week 15 Student One',
            'role' => 'student',
            'office' => null,
        ]);

        $studentTwo = User::factory()->create([
            'name' => 'Week 15 Student Two',
            'role' => 'student',
            'office' => null,
        ]);

        $privateFeedback = new Feedback();
        $privateFeedback->user_id = $studentOne->id;
        $privateFeedback->student_name = $studentOne->name;
        $privateFeedback->title = 'Student One Private Feedback';
        $privateFeedback->category = 'Academic';
        $privateFeedback->description = 'This belongs to student one.';
        $privateFeedback->assigned_office = 'Academic Affairs Office';
        $privateFeedback->status = 'Pending';
        $privateFeedback->save();

        // Authenticate as the second student.
        Sanctum::actingAs($studentTwo);

        // Direct access to another student's feedback must fail.
        $this->getJson('/api/feedback/' . $privateFeedback->id)
            ->assertStatus(404);

        // The feedback list must not expose the private record.
        $this->getJson('/api/feedback')
            ->assertStatus(200)
            ->assertJsonCount(0);

        // The protected record must remain unchanged.
        $this->assertDatabaseHas('feedback', [
            'id' => $privateFeedback->id,
            'user_id' => $studentOne->id,
            'title' => 'Student One Private Feedback',
        ]);
    }

    public function test_student_can_view_their_own_feedback(): void
    {
        $student = User::factory()->create([
            'name' => 'Week 15 Feedback Owner',
            'role' => 'student',
            'office' => null,
        ]);

        $feedback = new Feedback();
        $feedback->user_id = $student->id;
        $feedback->student_name = $student->name;
        $feedback->title = 'My Own Feedback';
        $feedback->category = 'Facilities';
        $feedback->description = 'A feedback record belonging to this student.';
        $feedback->assigned_office = 'Facilities Management Office';
        $feedback->status = 'Pending';
        $feedback->save();

        Sanctum::actingAs($student);

        $this->getJson('/api/feedback/' . $feedback->id)
            ->assertStatus(200)
            ->assertJsonPath('id', $feedback->id)
            ->assertJsonPath('user_id', $student->id)
            ->assertJsonPath('title', 'My Own Feedback');

        $this->getJson('/api/feedback')
            ->assertStatus(200)
            ->assertJsonCount(1)
            ->assertJsonFragment([
                'title' => 'My Own Feedback',
            ]);
    }
}
