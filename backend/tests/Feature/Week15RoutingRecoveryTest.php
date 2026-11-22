<?php

namespace Tests\Feature;

use App\Models\Feedback;
use App\Models\User;
use App\Services\FeedbackRoutingService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class Week15RoutingRecoveryTest extends TestCase
{
    use RefreshDatabase;

    public function test_failed_routing_creates_manual_review_escalation(): void
    {
        // Create a temporary student.
        $student = User::factory()->create([
            'name' => 'Week 15 Recovery Student',
            'role' => 'student',
            'office' => null,
        ]);

        // Create a test record directly to simulate a
        // routing failure that normal API validation prevents.
        $feedback = new Feedback();

        $feedback->user_id = $student->id;
        $feedback->student_name = $student->name;
        $feedback->title = 'Week 15 Routing Failure Test';
        $feedback->category = 'Unsupported Category';
        $feedback->description =
            'Simulated failure to verify routing recovery.';
        $feedback->status = 'Pending';

        $feedback->save();

        // Run the actual routing service.
        $routingService = app(FeedbackRoutingService::class);

        $result = $routingService->route($feedback);

        // Routing must report failure after its retry limit.
        $this->assertFalse($result);

        // Feedback remains saved for manual review.
        $this->assertDatabaseHas('feedback', [
            'id' => $feedback->id,
            'user_id' => $student->id,
            'status' => 'Pending',
            'assigned_office' => null,
        ]);

        // The failure must be recorded with retry metadata.
        $this->assertDatabaseHas('automation_logs', [
            'feedback_id' => $feedback->id,
            'action' => 'Automatic Feedback Routing',
            'status' => 'Failed',
            'retry_count' => 2,
            'max_retries' => 3,
            'requires_manual_review' => true,
            'error_message' =>
                'Automatic routing failed. Manual review required.',
        ]);

        // Administration must receive an escalation record.
        $this->assertDatabaseHas('feedback_notifications', [
            'feedback_id' => $feedback->id,
            'recipient_office' => 'General Administration Office',
            'notification_type' => 'Escalation',
            'status' => 'Unread',
        ]);

        // Failed attempts must not create duplicate records.
        $this->assertDatabaseCount('feedback', 1);
        $this->assertDatabaseCount('automation_logs', 1);
        $this->assertDatabaseCount('feedback_notifications', 1);
    }
}
