<?php

namespace App\Services;

use App\Models\Feedback;
use App\Models\AutomationLog;
use App\Models\FeedbackNotification;
use Illuminate\Support\Facades\DB;
use Throwable;

class FeedbackRoutingService
{
    private const MAX_ATTEMPTS = 3;

    private const OFFICE_ROUTING = [
        'Academic' => 'Academic Affairs Office',
        'Facilities' => 'Facilities Management Office',
        'Student Services' => 'Student Services Office',
        'Others' => 'General Administration Office',
    ];

    public function route(Feedback $feedback): bool
    {
        for (
            $attempt = 1;
            $attempt <= self::MAX_ATTEMPTS;
            $attempt++
        ) {
            try {
                DB::transaction(function () use ($feedback) {

                    // Find the office based on feedback category
                    $office = self::OFFICE_ROUTING[$feedback->category]
                        ?? throw new \RuntimeException(
                            'No office configured for this category.'
                        );

                    // Update feedback assignment and status
                    $feedback->update([
                        'assigned_office' => $office,
                        'status' => 'Pending',
                    ]);

                    // Generate notification for assigned office
                    FeedbackNotification::create([
                        'feedback_id' => $feedback->id,
                        'recipient_office' => $office,
                        'notification_type' => 'Assignment',
                        'message' => 'New feedback assigned: '
                            . $feedback->title,
                        'status' => 'Unread',
                    ]);

                    // Record successful automation
                    AutomationLog::create([
                        'feedback_id' => $feedback->id,
                        'action' => 'Automatic Feedback Routing',
                        'status' => 'Success',
                        'details' => 'Feedback assigned to ' . $office,
                        'retry_count' => 0,
                        'max_retries' => self::MAX_ATTEMPTS,
                        'requires_manual_review' => false,
                    ]);
                });

                return true;

            } catch (Throwable $exception) {

                // Maximum attempts reached
                if ($attempt === self::MAX_ATTEMPTS) {

                    DB::transaction(function () use (
                        $feedback,
                        $attempt,
                        $exception
                    ) {

                        // Record failed routing
                        AutomationLog::create([
                            'feedback_id' => $feedback->id,
                            'action' => 'Automatic Feedback Routing',
                            'status' => 'Failed',
                            'details' => 'Routing failed after maximum attempts.',
                            'retry_count' => $attempt - 1,
                            'max_retries' => self::MAX_ATTEMPTS,
                            'error_message' => $exception->getMessage(),
                            'requires_manual_review' => true,
                        ]);

                        // Notify administration for manual review
                        FeedbackNotification::create([
                            'feedback_id' => $feedback->id,
                            'recipient_office' => 'General Administration Office',
                            'notification_type' => 'Escalation',
                            'message' => 'Manual review required for feedback ID '
                                . $feedback->id,
                            'status' => 'Unread',
                        ]);
                    });

                    return false;
                }

                // Wait before retrying
                usleep(200000);
            }
        }

        return false;
    }
}
