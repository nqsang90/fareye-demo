<?php

namespace App\Http\Controllers;

use App\TransactionUpdate;
use Illuminate\Http\Request;

class TransactionUpdateController extends Controller
{
    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $transaction_updates = TransactionUpdate::query()
            ->orderBy('id', 'desc')
            ->paginate(10);
        $data['transaction_updates']  = $transaction_updates;
        return view('transaction_updates/list', $data);
    }
}
