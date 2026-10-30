<?php

namespace App\Http\Controllers\Api;

use App\Services\FeedbackRoutingService;
use App\Http\Controllers\Controller;
use App\Models\Feedback;
use App\Models\AutomationLog;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class FeedbackController extends Controller
{
    // Retrieve all feedback records
    public function index()
    {
        return response()->json(
            Feedback::latest()->get()
        );
    }

    // Submit new student feedback

public function store(
    Request $request,
    FeedbackRoutingService $routingService
) {
    $validated = $request->validate([
        'student_name' => 'required|string|max:255',
        'title' => 'required|string|max:255',
        'category' => 'required|in:Academic,Facilities,Student Services,Others',
        'description' => 'required|string|max:5000',
    ]);

    $validated['status'] = 'Pending';

    $feedback = Feedback::create($validated);

    $routed = $routingService->route($feedback);

    $feedback->refresh();

    return response()->json([
        'message' => $routed
            ? 'Feedback submitted and routed successfully!'
            : 'Feedback saved, but routing requires manual review.',
        'feedback' => $feedback,
        'routing_success' => $routed,
    ], 201);
}


    // Retrieve a specific feedback record
    public function show(Feedback $feedback)
    {
        return response()->json($feedback);
    }
}
