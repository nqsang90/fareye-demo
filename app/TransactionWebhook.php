<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class TransactionWebhook extends Model
{
    const codes = [];
    public function receiveUpdate(TransactionUpdate $update)
    {
        try {
            $update->save();
        }
        catch (\Exception $exception) {
        }
    }
}
