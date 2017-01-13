<?php

namespace App\Providers;

use App\TransactionWebhook;
use Illuminate\Support\ServiceProvider;

class TransactionUpdate extends ServiceProvider
{
    /**
     * Bootstrap the application services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }

    /**
     * Register the application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton(TransactionWebhook::class, function ($app) {
            return new TransactionWebhook();
        });
    }
}
