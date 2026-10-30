<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Feedback extends Model
{
    protected $table = 'feedback';

    protected $fillable = [
        'student_name',
        'title',
        'category',
        'description',
        'assigned_office',
        'status',
    ];
}
