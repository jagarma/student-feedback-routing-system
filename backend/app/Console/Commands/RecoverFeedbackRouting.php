<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Feedback;
use App\Models\AutomationLog;
use Illuminate\Support\Facades\DB;

class RecoverFeedbackRouting extends Command
{
    protected $signature = 'feedback:recover
        {feedback_id : ID of feedback requiring manual review}
        {--office= : Office selected by the staff member}';

    protected $description = 'Manually recover a failed feedback routing';

    public function handle(): int
    {
        $feedback = Feedback::find($this->argument('feedback_id'));

        if (!$feedback) {
            $this->error('Feedback record not found.');
            return self::FAILURE;
        }

        $failedLog = AutomationLog::where('feedback_id', $feedback->id)
            ->where('requires_manual_review', true)
            ->latest()
            ->first();

        if (!$failedLog) {
            $this->error('No unresolved manual review found.');
            return self::FAILURE;
        }

        $offices = [
            'Academic Affairs Office',
            'Facilities Management Office',
            'Student Services Office',
            'General Administration Office',
        ];

        $office = $this->option('office');

        if (!$office) {
            $office = $this->choice(
                'Select the office for manual assignment',
                $offices
            );
        }

        if (!in_array($office, $offices, true)) {
            $this->error('Invalid office selected.');
            return self::FAILURE;
        }

        DB::transaction(function () use ($feedback, $failedLog, $office) {
            $feedback->update([
                'assigned_office' => $office,
                'status' => 'Pending',
            ]);

            $failedLog->update([
                'requires_manual_review' => false,
            ]);

            AutomationLog::create([
                'feedback_id' => $feedback->id,
                'action' => 'Manual Routing Recovery',
                'status' => 'Success',
                'details' => 'Feedback manually assigned to ' . $office,
                'retry_count' => 0,
                'max_retries' => 3,
                'requires_manual_review' => false,
            ]);
        });

        $this->info('Manual recovery completed successfully!');
        $this->info('Feedback ID: ' . $feedback->id);
        $this->info('Assigned Office: ' . $office);

        return self::SUCCESS;
    }
}
