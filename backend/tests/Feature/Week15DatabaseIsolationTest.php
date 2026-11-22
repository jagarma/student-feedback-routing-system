<?php

namespace Tests\Feature;

use Tests\TestCase;

class Week15DatabaseIsolationTest extends TestCase
{
    public function test_automated_tests_use_in_memory_sqlite(): void
    {
        $this->assertEquals(
            'testing',
            app()->environment()
        );

        $this->assertEquals(
            'sqlite',
            config('database.default')
        );

        $this->assertEquals(
            ':memory:',
            config('database.connections.sqlite.database')
        );

        $this->assertEquals(
            'sqlite',
            \DB::connection()->getDriverName()
        );

        $this->assertTrue(
            \DB::connection()->getPdo() instanceof \PDO
        );
    }
}
