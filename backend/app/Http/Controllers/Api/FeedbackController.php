<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Feedback;
use App\Services\FeedbackRoutingService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FeedbackController extends Controller
{
    /**
     * List feedback accessible to the authenticated user.
     */
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->isStudent()) {
            $feedback = Feedback::where('user_id', $user->id)
                ->latest()
                ->get();

            return response()->json($feedback);
        }

        if ($user->isStaff() && !empty($user->office)) {
            $feedback = Feedback::where(
                'assigned_office',
                $user->office
            )->latest()->get();

            return response()->json($feedback);
        }

        return response()->json([
            'message' => 'You are not authorized to view feedback.',
        ], 403);
    }

    /**
     * Submit feedback as an authenticated student.
     */
    public function store(
        Request $request,
        FeedbackRoutingService $routingService
    ): JsonResponse {
        $user = $request->user();

        if (!$user->isStudent()) {
            return response()->json([
                'message' => 'Only students can submit feedback.',
            ], 403);
        }

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'category' => [
                'required',
                'in:Academic,Facilities,Student Services,Others',
            ],
            'description' => [
                'required',
                'string',
                'max:5000',
            ],
        ]);

        $feedback = new Feedback();

        // Ownership and identity come from the authenticated account.
        $feedback->user_id = $user->id;
        $feedback->student_name = $user->name;

        $feedback->title = $validated['title'];
        $feedback->category = $validated['category'];
        $feedback->description = $validated['description'];
        $feedback->status = 'Pending';

        $feedback->save();

        // Preserve Week 13 automatic routing and recovery behavior.
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

    /**
     * View one feedback record with ownership restrictions.
     */
    public function show(Request $request, Feedback $feedback): JsonResponse
    {
        $user = $request->user();

        if ($user->isStudent()) {
            if ((int) $feedback->user_id !== (int) $user->id) {
                return response()->json([
                    'message' => 'Feedback not found.',
                ], 404);
            }

            return response()->json($feedback);
        }

        if ($user->isStaff()
            && !empty($user->office)
            && $feedback->assigned_office === $user->office) {
            return response()->json($feedback);
        }

        return response()->json([
            'message' => 'Feedback not found.',
        ], 404);
    }
}
