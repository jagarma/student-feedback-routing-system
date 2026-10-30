<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('feedback_notifications', function (Blueprint $table) {
            $table->id();

            $table->foreignId('feedback_id')
                ->constrained('feedback')
                ->cascadeOnDelete();

            $table->string('recipient_office');
            $table->string('notification_type');
            $table->text('message');
            $table->string('status')->default('Unread');
            $table->timestamp('read_at')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('feedback_notifications');
    }
};
