<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\FeedbackController;

Route::get('/feedback', [FeedbackController::class, 'index']);

Route::post('/feedback', [FeedbackController::class, 'store']);

Route::get('/feedback/{feedback}', [FeedbackController::class, 'show']);

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');
