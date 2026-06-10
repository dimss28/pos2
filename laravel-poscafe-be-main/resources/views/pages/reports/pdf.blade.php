<!DOCTYPE html><html><head><meta charset="UTF-8">
<style>
body { font-family: sans-serif; font-size: 11px; color: #333; }
h2 { font-size: 16px; margin-bottom: 4px; }
p { margin: 0 0 12px; color: #666; }
table { width: 100%; border-collapse: collapse; }
th { background: #f0f0f0; font-weight: bold; text-align: left; padding: 6px 8px; border-bottom: 2px solid #ccc; }
td { padding: 5px 8px; border-bottom: 1px solid #eee; }
</style>
</head><body>
<h2>Laporan {{ ucfirst($title) }}</h2>
<p>{{ formatDate($from,'d M Y') }} — {{ formatDate($to,'d M Y') }}</p>
<table>
    <thead><tr>@foreach($headings as $h)<th>{{ $h }}</th>@endforeach</tr></thead>
    <tbody>
        @foreach($rows as $row)<tr>@foreach($row as $cell)<td>{{ $cell }}</td>@endforeach</tr>@endforeach
    </tbody>
</table>
</body></html>
