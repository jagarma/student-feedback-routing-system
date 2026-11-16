<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use RuntimeException;

class Week14TestUsersSeeder extends Seeder
{
    public function run(): void
    {
        if (app()->environment('production')) {
            throw new RuntimeException(
                'Test accounts cannot be seeded in production.'
            );
        }

        $password = env('WEEK14_TEST_PASSWORD');

        if (!is_string($password) || strlen($password) < 12) {
            throw new RuntimeException(
                'Set WEEK14_TEST_PASSWORD in your local .env file with at least 12 characters.'
            );
        }

        $accounts = [
            [
                'name' => 'Test Student',
                'email' => 'student.week14@example.test',
                'role' => 'student',
                'office' => null,
            ],
            [
                'name' => 'Academic Affairs Test Staff',
                'email' => 'academic.week14@example.test',
                'role' => 'staff',
                'office' => 'Academic Affairs Office',
            ],
            [
                'name' => 'Facilities Test Staff',
                'email' => 'facilities.week14@example.test',
                'role' => 'staff',
                'office' => 'Facilities Management Office',
            ],
        ];

        foreach ($accounts as $account) {
            DB::transaction(function () use ($account, $password) {
                $user = User::firstOrNew([
                    'email' => $account['email'],
                ]);

                if ($user->exists) {
                    throw new RuntimeException(
                        'Account already exists: ' . $account['email'] .
                        '. Existing accounts will not be overwritten.'
                    );
                }

                $user->name = $account['name'];
                $user->password = Hash::make($password);
                $user->role = $account['role'];
                $user->office = $account['office'];
                $user->save();
            });
        }

        $this->command->info(
            'Week 14 test accounts created successfully.'
        );
    }
}
