<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
       Schema::create('feedback', function (Blueprint $table) {
         $table->id();
         $table->string('student_name');
         $table->string('title');
         $table->string('category');
         $table->text('description');
         $table->string('assigned_office')->nullable();
         $table->string('status')->default('Pending');
         $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('feedback');
    }
};
