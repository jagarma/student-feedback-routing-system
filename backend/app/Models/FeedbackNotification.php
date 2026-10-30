<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FeedbackNotification extends Model
{
    protected $fillable = [
        'feedback_id',
        'recipient_office',
        'notification_type',
        'message',
        'status',
        'read_at',
    ];

    protected $casts = [
        'read_at' => 'datetime',
    ];
}
