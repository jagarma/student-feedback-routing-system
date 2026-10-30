<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('automation_logs', function (Blueprint $table) {
            $table->unsignedInteger('retry_count')->default(0);
            $table->unsignedInteger('max_retries')->default(3);
            $table->text('error_message')->nullable();
            $table->boolean('requires_manual_review')->default(false);
        });
    }

    public function down(): void
    {
        Schema::table('automation_logs', function (Blueprint $table) {
            $table->dropColumn([
                'retry_count',
                'max_retries',
                'error_message',
                'requires_manual_review',
            ]);
        });
    }
};
