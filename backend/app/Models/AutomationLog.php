<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AutomationLog extends Model
{
   
protected $fillable = [
    'feedback_id',
    'action',
    'status',
    'details',
    'retry_count',
    'max_retries',
    'error_message',
    'requires_manual_review',
];

protected $casts = [
    'requires_manual_review' => 'boolean',
];

}
