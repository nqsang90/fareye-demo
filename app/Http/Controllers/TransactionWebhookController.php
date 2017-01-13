<?php

namespace App\Http\Controllers;

use App\TransactionUpdate;
use App\TransactionWebhook;
use Illuminate\Http\Request;

class TransactionWebhookController extends Controller
{
    protected $webhookService;
    public function __construct(TransactionWebhook $webhookService)
    {
        $this->webhookService = $webhookService;
        $this->middleware('auth:api');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Http\Response
     */
    public function index(Request $request)
    {
        $data = array();
        $update = new TransactionUpdate();
        $update->job_type = $request->jobType;
        $update->reference_no = $request->referenceNo;
        $update->hub_code = $request->hubCode;
        $update->transaction_date = $request->transactionDate;
        $update->status = $request->status;
        $update->data = \json_encode($request->all());
        try {
            $this->webhookService->receiveUpdate($update);
            $data['status']  = 'success';
            $data['message'] = 'Update received successfully';
        }
        catch (\Exception $exception) {
            $data['status'] = 'error';
            $data['message'] = $exception->getMessage();
        }
        return response()->json($data);
    }
}
