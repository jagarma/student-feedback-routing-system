<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FeedbackController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public Authentication Route
|--------------------------------------------------------------------------
*/

Route::post('/login', [AuthController::class, 'login'])
    ->middleware('throttle:10,1');

/*
|--------------------------------------------------------------------------
| Protected API Routes — Week 14
|--------------------------------------------------------------------------
*/

Route::middleware('auth:sanctum')->group(function () {

    // Authentication
    Route::get('/me', [AuthController::class, 'me']);

    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Feedback
    Route::get('/feedback', [FeedbackController::class, 'index']);

    Route::post('/feedback', [FeedbackController::class, 'store']);

    Route::get('/feedback/{feedback}', [FeedbackController::class, 'show']);
});
