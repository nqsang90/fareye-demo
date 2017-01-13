@extends('layouts.app')

@section('content')
    <div class="container">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="panel panel-default">
                </div>
            </div>
        </div>
        <div>
            <table id="transaction-updates" class="table table-hover">
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Job Type</th>
                    <th>Reference No</th>
                    <th>Status</th>
                    <th>Transaction date</th>
                    <th>Data</th>
                </tr>
                <tbody>
                @foreach ($transaction_updates as $update)
                    <tr>
                        <td>{{ $update->id }}</td>
                        <td>{{ $update->job_type }}</td>
                        <td>{{ $update->reference_no }}</td>
                        <td>{{ $update->status }}</td>
                        <td>{{ $update->transaction_date }}</td>
                        <td class="json-stringified">{{ $update->data }}</td>
                    </tr>
                @endforeach
                </tbody>
                </thead>
            </table>
            {{ $transaction_updates->links() }}
        </div>
    </div>
@endsection
