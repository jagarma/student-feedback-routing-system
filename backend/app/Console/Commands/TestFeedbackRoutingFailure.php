<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Feedback;
use App\Services\FeedbackRoutingService;

class TestFeedbackRoutingFailure extends Command
{
    protected $signature = 'feedback:test-routing-failure';

    protected $description = 'Test routing failure and manual review';

    public function handle(
        FeedbackRoutingService $routingService
    ): int {
        $feedback = Feedback::create([
            'student_name' => 'Automation Test Student',
            'title' => 'Controlled Routing Failure Test',
            'category' => 'Invalid Test Category',
            'description' => 'Testing the routing recovery workflow.',
            'status' => 'Pending',
        ]);

        $this->info('Test feedback ID: ' . $feedback->id);

        $success = $routingService->route($feedback);

        if (!$success) {
            $this->warn(
                'Routing failed after maximum attempts.'
            );
            $this->warn(
                'Feedback requires manual review.'
            );
        } else {
            $this->info('Routing succeeded.');
        }

        return self::SUCCESS;
    }
}
