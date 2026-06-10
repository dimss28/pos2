@if (session('success'))
    <script>setTimeout(() => window.AppToast?.('success', @json(session('success'))), 50);</script>
@endif
@if (session('error'))
    <script>setTimeout(() => window.AppToast?.('error', @json(session('error'))), 50);</script>
@endif
@if (session('status'))
    <script>setTimeout(() => window.AppToast?.('info', @json(session('status'))), 50);</script>
@endif
